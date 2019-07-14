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

12. Now let's run it. Did it fail due to variable issues? Something like `Error: Reference to undeclared resource`? Well shoot...let's fix that by allowing cross-access to variables amongst modules. Whilst this isn't __ideal__...it's possible (and not too difficult, fortunately). Let's take care of that now.... with a quick pause for an explanation.

13. An important rule of terraform with passing variables around is this:
    * **Parent** modules (in this case our **root** module) pass variables to **child** modules via the **variables.tf** file
    * **Child** modules pass variables to the **parent** modules via the **output.tf** file!

14. So we're going to demonstrate that here! We want to pass a variable (the VPC ID) from a __parent__ module (the root where VPC is being created) down to a __child__ module (the webserver module). To do that we're going to start by going into the __child__ module (read: **webserver**) and adding this to the **variables.tf** folder

```terraform
variable "main_vpc_id" {
    type = "string"
}
```

15. Now we just need to quickly go into the resource itself (the webserver) and change this line to use that empty variable (line 15 for me):
```terraform
resource "aws_security_group" "ssh_access" {
  name = "ssh_access"
  vpc_id = **var.main_vpc_id
  ingress {
      ...

```

16. Now hopefully you guys remember what happens with an empty variable? **It needs an input!**. So we're going to go ahead and __add__ that input to the module itself as follows in the root **main.tf**:

```terraform

module "webserver" {
    source = "./modules/services/webserver"
    main_vpc_id = module.vpc.vpc_id_so_we_can_spot_easily
}
```

17. Now notice the difference here- we now have a module that is using the **output** from another module (if you look in `./modules/vpc/outputs.tf` you'll see where this output is defined!).

18. If you `terraform plan` now you'll see that the error has moved on.

19. Go ahead and correct all of the missing variables using this tactic! ALSO (this is coming up in the **challenges**- you now have the tools to make the ENVIRONMENT tag universal. Go ahead and do that now!)

## Using data sources

1. __Data sources__ allow data to be fetched or computed for use elsewhere in Terraform configuration. Use of data sources allows a Terraform configuration to make use of information defined outside of Terraform, or defined by another separate Terraform configuration.

2. Basically what the **data sources** are doing is querying, via api, resources that have already been created and then using those resources in OTHER resources to help define them! **data sources don't actually create anything!!**. They SOLELY exist to get information about resources that are outside of the scope of your immediate terraform use.

3. If you haven't yet- go ahead and deploy your current stack:

![makeitso](../../images/makeitso.png)

4. So now that our stack is freshly deployed let's get data about something that we __haven't__ deployed as part of our stack (just to show how data_source works)! The one thing we haven't put up in advance yet is our **user**...so let's grab information about him/her. 

5. Go into your top level **variables.tf** folder and add this line (obviously replacing the **user_name** with the **user_name** you created at the beginning of this class).

```terraform
data "aws_iam_user" "helloitsme" {
  user_name = "dimos"
}
```

6. If you would like you can get other data source information found [here](https://www.terraform.io/docs/providers/aws/d/vpc.html) (you can see on the left side all of the different options- from **ami** to different types of user data). 

7. Go into your **outputs.tf** file on the top (root) level and add in this line:

```terraform
output "main_vpc_id" {
    description = "The ID of the root VPC for this project"
    value = module.vpc.vpc_id_so_we_can_spot_easily
}

output "user_data" {
    value = data.aws_iam_user.helloitsme
}
```

8. Now `terraform apply` again and you should get a sense of what the `data source` does for you. Remember- the **user** was created __outside__ of our terraform here...but we're able to use the AWS API to pull that data down __anyway__ and use it for the user. Now..instead of just outputing this we can use it to, for example, put our resources into **already existing** vpcs

## Provisioning EC2 instances


### Basic provisioning

1. So at this point we should have some idea of how all of this comes together. The next thing we need to look at is how we're going to PROVISION these ec2 instances. While it's interesting and fun and all to have EC2 instances created and ssh-ing into them...it really doesn't do us much good unless we can set them to actually, you know...DO something.

2. So- before we jump into various provisioning tools let's run a very basic, straightforward provision by creating some text files and adding a few bits of code to our newly created ec2 "web" server! This should be a good example of how a provisioner works...

3. Without a native-to-terraform provisioner there are basically two options available to us: 
    * The **local-exec** which is run on the local machine after a resource is created.
    * The **remote-exec** which basically runs on the __on the resource__ by ssh-accessing the ec2 instance and executing. Obviously for this one you'll need to provide connection information (i.e: ssh access keys) in order to run the program on the remote machine.

4. So let's start with a fairly straightforward, basic code execution. Let's add in a webserver! BEFORE we do anything else we'll have to `terraform destroy` all of our existing infrastructure (**remote-exec** is intended to run when the ec2 instance is created so for it to work for us we need to re-create the ec2 instance!

5. To do that we'll need to add in a **provisioner** under our ec2 instance that will **remote-exec** a basic command. Something like (in **./modules/webserver/main.tf** under our __existing__ ec2 instance):

```terraform
resource "aws_instance" "myfirstec2" {
  ami           = var.ec2type
  instance_type = "t2.micro"
  key_name = "myec2key"
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  

provisioner "file" {
    source = "/Users/fernandopombeiro/github_projects/terraform-developintelligence/module_03/app/terraform/build.sh"
    destination = "/home/ec2-user/build.sh"
}

provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/build.sh",
      "sudo yes | sh build.sh",
      "echo OMG_this_is_totally_working_jenkins > hereisafile.txt",
    ]
}
     connection {
        host        = aws_instance.myfirstec2.public_dns
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("./keys/practicekey")}"
        }


provisioner "local-exec"  {
    command= "echo ${aws_instance.myfirstec2.public_ip} >> ./hereistheip.txt"
}

  tags = {
      Environment = var.environment_tag
    }
}

```

3. Now let's ssh back into our ec2 instance (go to the gui and grab the connection information, except alter "mykey.pem" to your "practicekey") What do we see? __hopefully__ you see something that looks like a file there and if you cat that out you get our message. NOW- think of what you can do with this thing for some **real** provisioning! (i.e: Jenkins servers, etc)

4. Now let's go back and create a LOCAL file to execute ON the ec2 instance! Before we do that we need to `terraform destroy` our resources again and switch the ec2. 

5. Add in a **build.sh** file in the root directory of the `./terraform` module (obviously this can be as complex or simple as you'd like). Fortunately there __are__ some simple servers, like **jenkins** that can be set up with just a few simple command line commands! In **./terraform/build.sh** add in this code to create the jenkins server:

```bash
#!bin/bash

sudo yum update;
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo;
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key;
sudo yum install java;
sudo yum install jenkins;
```

6. Now we're going to send the file up to the ec2 instance and then run it as a basic **sh**. To do this we'll need to add to the **provisioner** here so that everything is set on where and how to send the file...so do this in your **webserver/main.tf** file (in that module):

```terraform
resource "aws_instance" "myfirstec2" {
  ami           = var.ec2type
  instance_type = "t2.micro"
  key_name = "myec2key"
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  

provisioner "file" {
    source = "/Users/fernandopombeiro/github_projects/terraform-developintelligence/module_03/app/terraform/build.sh"
    destination = "/home/ec2-user/build.sh"
}

provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/build.sh",
      "sudo yes | sh build.sh",
      "echo OMG_this_is_totally_working_jenkins > hereisafile.txt",
    ]
}
     connection {
        host        = aws_instance.myfirstec2.public_dns
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("./keys/practicekey")}"
        }


provisioner "local-exec"  {
    command= "echo ${aws_instance.myfirstec2.public_ip} >> ./hereistheip.txt"
}

```

7. Notice in the above that we are using both a **remote-exec** (to be run on the instance) and then a **local-exec** (to be run on our host) to take care of creating a file upon completion of the provisioning. This can be useful for sending IP addresses to a centralized repository every time an instance is created- i.e: a `curl -X POST` command that **posts** the IP address of the newly created instance to an API that has a list somewhere (like on an FTP server or something).

8. Finally- with this example we're demonstrating how __amazingly easy__ it is to create a full jenkins server for CI/CD if you need one!! This can be extremely handy if anything goes wrong with jenkins elsewhere!

9. At the end you should have a file appear in your terraform directory called **hereistheip.txt**. Check it out and see if everything worked!

### Third Party Provisioners

1. So along with basic **bash** scripts there are plenty of third party provisioners currently available to help us with provisioning large numbers of ec2 instances. There are programs like [ansible](https://www.ansible.com/), [chef](https://www.packer.io/docs/provisioners/chef-client.html), and [puppet](https://puppet.com/). All have their advantages and drawbacks- buy for today we're going to go with **ansible**

2. Since going into everything with ansible is outside of the scope of this class let's create a very quick web app that installs and starts running an ansible provisioner utilizing our **local-exec** and **remote-exec** methods. 

3. One quick note- for this to work we're going to need to create an ingress into our vpc and ec2 instance for web traffic. Now- as we know web traffic for a basic http site comes in via port **80** so we need to open that up before we can create a web server. Head over to your **webserver/main.tf** module and let's add in an ingress (and connect it to our ec2 instance):

```terraform
resource "aws_security_group" "sg_80" {
  name = "sg_80"
  vpc_id = var.main_vpc_id

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

4. And we need to add to our ec2 instance:

```terraform
resource "aws_instance" "myfirstec2" {
  ami           = var.ec2type
  instance_type = "t2.micro"
  key_name = "myec2key"
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_access.id, aws_security_group.sg_80.id]

  ...

```
5. Now to run our ansible scripts...so the question here is the best order to do this in...remember- our choices are for **remote** or **local** executions and each have their drawbacks. We're also going to have to move our website files up to our new EC2 instance which means more file provisioners as well... though fortunately we have ansible doing a lot of that for us.

6. Let's add this **local-exec** since we need ansible to wait until everything is completed. SO- let's make everything look like this in **webservers/main.tf**

```terraform
resource "aws_instance" "myfirstec2" {
  ami           = var.ec2type
  instance_type = "t2.micro"
  key_name = "myec2key"
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_access.id, aws_security_group.sg_80.id]

  provisioner "remote-exec" {
    inline = ["sudo yum -y install python"]

     connection {
        host        = self.public_dns
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("./keys/practicekey")}"
    }
  }


provisioner "local-exec" {
    command = "ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ./keys/practicekey ../ansible/playbook.yaml" 
  }

  tags = {
      Environment = var.environment_tag
    }
}

resource "aws_security_group" "ssh_access" {
  name = "ssh_access"
  vpc_id = var.main_vpc_id
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

resource "aws_security_group" "sg_80" {
  name = "sg_80"
  vpc_id = var.main_vpc_id

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

7. And finally, just to make our lives easier, let's add the public dns of our site to our **outputs.tf** file on the root level:

```terraform
output "website_dns" {
    value = module.webserver.public_dns
}
```

8. *Okay- let's do it!!* (You know the commands by now!)

![makeitso](../../images/makeitso.png)

9. Congrats! Let's `terraform destroy`!!


### NULL resources

1. So as you might have noticed...every time we want to re-run our ansible playbook the ec2 instance was destroyed and a new one created. This...could be problematic in some instances where we want to decouple "provisioning" from "creating". Enter the **null resource**

2. The technical definition of the **null resource** is that it implements the standard resource lifecycle but takes no further action. Translated from hashicorp speak this means that it will kind of __act__ like a resource but will not actually __create__ a resource. So why is this a good thing for us? 

3. Well- as we saw from provisioning- the ec2 instances are created and destroyed with every change. __What if__ instead of creating a single ec2 resource you were creating a cluster of **three**, right? And, of course, being the awesome dev/ops that you are you have provisioners that you want to run on all three as a separate resource? What if you wanted these provisioners to be **triggered** at the creation of each ec2 instance?

4. **Null Resources** have a variable called **trigger** that, when changed, will **trigger** that null resource to run something (90% of the time it's a provisioner) on that node. SO- let's update our webserver code fairly simply by turning our instance into a **cluster of instances** as such (in **module/webserver/main.tf**):

```terraform
resource "aws_instance" "myfirstec2" {
  count = 3
  ...
```

5. Now if we run we'll have a three node cluster...but let's say we wanted to __decouple provisioning from the creation__! This would mean taking the provisioners **out** of the aws_instance resource and placing them in a **null resource** with the same name as the aws resource as such:

```terraform
resource "aws_instance" "myfirstec2" {
  count = 3
  ami           = var.ec2type
  instance_type = "t2.micro"
  key_name = "myec2key"
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_access.id, aws_security_group.sg_80.id]

}

resource "null_resource" "myfirstec2" {
    triggers = {
        cluster_instance_ids = join("," aws_instance.myfirstec2.*.id)
    }
    provisioner "remote-exec" {
        inline = ["sudo yum -y install python"]
    
    connection {
        host        = self.public_dns
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("./keys/practicekey")}"
    }
  }
    provisioner "local-exec" {
        command = "ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ./keys/practicekey ../ansible/playbook.yaml" 
    }

  tags = {
      Environment = var.environment_tag
    }

}
```

6. A couple of things to note here:
    * Notice the use of the **join** statement; we've been remiss a bit on getting into some of these shortcuts but just like in code- we can create a list from strings using join
    * The * symbol there is the equivalent of a `for each` looper- so what that's saying is "for each of the ids that comes up get trigger". 

7. As a challenge- try to upgrade this to a three node cluster from a single node cluster; this will mean making significant changes to your code but I know you can do it! You'll probably notice an error now that your instance IPS are all in a list form. It's a great exercise to go through and figure out how to deal with that...

8. At the end of this lab don't forget to `terraform destroy`!