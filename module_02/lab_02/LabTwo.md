# Lab Two: Creating VPCs with Terraform

## VPC with EC2

1. As we went over in the lectures: VPCs are an essential ingredient in creating a network for your EC2 instance. In this lab we will be creating a VPC and placing **two** ec2 instances in it- one __public__ and one __private__.

2. Copy over all of the files from the previous section into your **app/** folder. Now- as we'll be adding a unique resource let's give it a personalized file. Add in a file called **vpc.tf**. That's where we'll put the vpc data. Also, while we're at it-- let's change the name from **main.tf** to **ec2.tf**. This is a huge advantage in terraform- we can organize our resources effectively into different files.

3. General advice here- when setting up a terraform infrastructure the best method is to START by going online and finding the resource and then kind of working backwards to fill it in. So in that spirit- let's __start__ by creating our vpc resource in our **vpc.tf** file. NOTE that you need to have your CIDR block here and we are allowing dns support and hostnames to allow easy access to the ec2 instance:

```terraform
resource "aws_vpc" "practice_vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Environment = var.environment_tag
  }
}
```

5. As you've probably noticed- there are a couple of variables there that we need to add back into our **variables.tf** blocks...so let's do that now:

```terraform
variable "cidr_vpc" {
  description = "CIDR block for our practice VPC"
  default = "10.1.0.0/16"
}

variable "environment_tag" {
  description = "This is the environment tag that we will use"
  default = "development"
}

```

6. Now we'll need a subnet WITHIN our vpc with it's own CIDR block within a given availability zone. So we're going to create that here to allow public access to our network (we're creating a web network after all!). So add this to your **vpc.tf**:

```terraform
resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.practice_vpc.id
  cidr_block = var.cidr_subnet
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone
  tags = {
    Environment = var.environment_tag
  }
}
```

7. In the above section notice the use of the reference to another resource (specifically **aws_vpc.practice_vpc.id**). Note from our lecture that this follows the format of __resource__ DOT __name__ DOT __parameter__...in this case the vpc ID- which is needed to link the subnet to the vpc.

8. Obviously we need the **cidr_subnet** variable and the **availability_zone** variables added...so let's hop onto that by adding these to **variables.tf**:

```terraform
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default = "10.1.0.0/24"
}
variable "availability_zone" {
  description = "availability zone to create subnet"
  default = "eu-west-1a"
}
```

9. Now- as stated before this is a __public__ subnet- so obviously we would like it to be internet-accessible (again- we'll do both a PUBLIC and PRIVATE subnet- the PRIVATE one will talk to our Database and be the location of most of our app code while the PUBLIC subnet will handle the front end). This means that a **gateway** is needed to allow internet access through our cloud network. This means a **gateway resource**

![gateway](./images/gateway.jpg)

10. Add the following to your **vpc.tf** file:

```terraform
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.practice_vpc.id
  tags = {
    Environment = var.environment_tag
  }
}
```

11. Now we need to add this aws gateway to our **route table** to allow ingress from the internets...and so to do that we'll have to add a route-table that references our vpc...so also in our **vpc.tf**:

```terraform
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.practice_vpc.id
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }
tags = {
    Environment = var.environment_tag
  }
}
```

12. So now we have a route-table connected to the internet-gateway but we still don't have the route-table associated to our "public" subnet...which means another resource to lock those two together: **aws_route_table_association**. Again: Notice the use of the reference to another resource. In **vpc.tf**:

```terraform
resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}
```

13. Okay- so Internet_gateway->Public_subnet->VPC looks good at this point. Basically the traffic will be routed IN through the internet gateway, through the **public** subnet which is part of the **VPC** (which can also hold a PRIVATE subnet for talking to our databases- which we'll get to). So the last thing we have to do is to edit our EC2 instance (in **main.tf**) and associate it with our vpc!

14. SO- to begin the association we probably want to lock down our EC2 instance and allow ingress **only** through ssh- which defaults to **port 22**. This means that port 22 must be **open** on our ec2 instance. To open and close various ports we'll want to use **security groups** which means, you guessed it...__another resource__. In **vpc.tf**:

```terraform
resource "aws_security_group" "ssh_access" {
  name = "ssh_access"
  vpc_id = aws_vpc.practice_vpc.id
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags =  {
    Environment = var.environment_tag
  }
}
```

15. Finally- let's associate __all__ of this VPC stuff with our ec2 instance by going BACK into **main.tf** and altering the ec2 instance there as follows:

```terraform
resource "aws_instance" "myfirstec2" {
  ami           = var.ec2type
  instance_type = "t2.micro"
  key_name = "myec2key"
  subnet_id = aws_subnet.subnet_public.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  
  tags = {
      Environment = var.environment_tag
  }
}
```

16. OKAY! That's it...we're ready to **init/plan/apply!**.

![makeitso](./images/makeitso.png)

17. As our last step we're going to go into the console and make sure that our "webserver" exists...so log into your aws account and check that it exists first:

![webserverexists](./images/webserverexists.png)

18. Now check that your new VPC and security groups exist by going to the VPC section in the management console and checking for TAGS (as we can't name the vpc on launch you can name it now...it's the one with the ENVIRONMENT: DEVELOPMENT tag associated with it):

![vpcverify](./images/vpcverify.png)

19. And finally...security groups...on the left side of the screen and it should have INBOUND RULES that say "PORT 22" is open:

![secgruverify](./images/secgruverify.png)

### OUTPUTS

1. So the biggest pain about that last scenario (when we are doing our verifications)was going in to the aws management console and figuring out which resource we created. NAME wasn't always associated (or possible to add)...so the ideal would be that once we create everything we would OUTPUT it. THAT (at long last) is where our OUTPUT.TF file will come in handy.

2. A couple of useful pieces of information from that last deployment might have been the public dns of our ec2 instance (although we haven't opened up port 80 or port 443 yet) and maybe the ID of our VPC so we know what to look for. In that spirit let's go ahead and add those in. 

3. BUT before we do that let's take a quick look at where they are __coming from__. Go to your console (from within your module_02 terraform directory) and type in `terraform show`. 

4. With that handy little list you can get information about all of the various resources that are deployed from within this particular terraform folder....specifically things like "Security group IDs", "VPC IDS" and "PUBLIC DNS'". We can use these in our **outputs.tf** file to output that information upon deployment of new resources. Hop over to that and add this line:

```terraform
output "public_dns" {
    value = aws_instance.myfirstec2.public_dns
}

output "public_ip" {
    value = aws_instance.myfirstec2.public_ip
}

output "vpc_id_so_we_can_spot_easily" {
    value = aws_vpc.practice_vpc.id
}
```

5. Now **plan** and **apply** again and see what comes up at the end!

6. Want to see another neat trick? Run `terraform output public_ip`. This basically echoes the output value to the command line SO...if you need to write a bash script for post-terraform deployments you can simply add this line in and echo out any output variables you created as a string!

7. ALSO- try running this feature: `terraform graph` and you get a nice little output of your dependencies. IF you're feeling fancy you can create a nice visualization of your current infrastructure with `terraform graph | dot -Tpng > graph.png`!
    * **WARNING**- if you're on mac you may have to install graphviz with `brew install graphviz`. If you're on windows you can install [here](https://graphviz.gitlab.io/download/)

