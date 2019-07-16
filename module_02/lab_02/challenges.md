# Module 02 Challenges

1. So now we have our network set up...let's see what else we can do with it! Add in an **api_gateway** to your setup and link it to your EC2 instance (so that data would come in via the api gateway and be processed on the EC2 instance). Output the url of the api gateway AND put it in the same VPC as your ec2 instance. What do you think- private or public? 

2. Create an **aws_lambda_function** resource and utilize the **api_gateway** resource as an input. How do  I get code into my **aws_lambda_function** in terraform? How do I link the **api_gateway** and the **aws_lambda_function** in a single network? 

3. Allow access to **port 3000** (which is the default for **node.js**) in a security group. Apply it to the VPC. Use that to open up communication between your **aws_lambda_function** and your **aws_instance**

4. Create a **mysql** rds instance in the cloud and wire it together with your lambda and api gateway resources. Open up port 3600 on it and put it in a security group that allows you to access it from anywhere. Output the link to access the database when the resources are finished building.

5. Add in an endpoint that just returns something like "hello there" to your api gateway and put it live on the internet (remember what ports you need to keep open on your VPC!)