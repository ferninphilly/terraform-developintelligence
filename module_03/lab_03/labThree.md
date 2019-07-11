# Lab Three: Modules and Provisioners

## Modularizing everything

1. So let's start with copying over our **app/** folder from our previous module. The first thing to notice is that, quite frankly, these files are getting a little out of control.

![disorganized](../../images/disorganized.jpg)

2. So our first order of business will be to moderate this monstrosity by using **modules** and then going with the recommended terraform layout used in production. This is what I recommend for the file layout:

```bash
stage
  └ vpc
  └ services
      └ frontend-app
      └ backend-app
  └ databases
      └ mysql
      └ redis
prod
  └ vpc
  └ services
      └ frontend-app
      └ backend-app
  └ data-storage
      └ mysql
      └ redis
mgmt
  └ vpc
  └ services
      └ bastion-host
      └ jenkins
global
  └ iam
  └ s3
```

3. So the advantages here should be obvious: you can deploy different modules depending on the environment (above I have **stage** and **prod** outlined). With these modules we can do all sorts of neat things like...sharing with the rest of the company and moving resource docs back and forth.

4. Let's start by creating a folder called "modules" in our **terraform** directory. This is where we're going to put some of our terraform resource documents. Inside this "modules" folder create a sub-folder called "services". Within that "services" file create a folder called "webserver"

5. Within "webserver" create your usual files: main, output and variables. SO- at this point you might see where we're going with this- we're going to create three separate modules: our **vpc**, our **database** and our **webserver**. 

6. As we continue on with this project we'll begin to add mode and more to this (**lambda**, **firehose**, **load balancers** etc)... but for now we're sticking with just these three because we want to start with some basic organization.

7. As you start this project think to yourself what variables each module would need access to. In our case both our **webserver** and our **database** modules would need access to **vpc**...so where do you think we should do that? 

8. Go ahead and set up your structure by moving your resources around as you see fit. Each of the modules (webserver, database, vpc) should have our three basics: main.tf, outputs.tf and variables.tf. In each of these should be the required data for that module. Please note that __the point here is to make these modules as decoupled as possible__ so that when you want you can send JUST the module to another developer and they can terraform from it on their own.

9. Considering the above- please also include a **README.md** in each module so that you have somewhere to advise a co-worker when they are wondering how your resources interact with each othe (again- the point of these modules is that you should be able to decouple them and move them around!). You can leave them blank for now but it's a good habit to get in to (specifically)

10. Once this is done you can go ahead and delete the resources at the top level as they should all be in modules now and your directory should look something like what was outlined above (extra credit if you added in the environment at the top level). 

11. I'm going to go ahead and post the answers below but please try not to look at them and figure this out on your own. 

### ./terraform/modules/services/webserver/main.tf

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

resource "aws_eip" "practice_eip" {
  vpc       = true
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_key_pair" "ec2key" {
  key_name   = "myec2key"
  public_key = file("./keys/practicekey.pub")
}
```

### ./terraform/modules/services/webserver/variables.tf

```terraform
variable "ec2type" {
    type = "string"
    description = "This is the ami for the type of ec2 instance we want to deploy"
    default = "ami-03746875d916becc0"
}

variable "key_pair_name" {
    type = "string"
    description = "The key pair to access our ec2 instance"
    default = "practicekey"
}
```

11. For now let's stop there and go into our top level `./terraform/main.tf` and put this in:

```terraform
provider "aws" {
  profile    =  var.profile
  region     =  var.region
}

module "webserver" {
    source = "./modules/services/webserver"
}
```

12. Now let's run it. Did it fail due to variable issues? Something like `Error: Reference to undeclared resource`? Well shoot...let's fix that by allowing cross-access to variables amongst modules. Whilst this isn't __ideal__...it's possible (and not )
