# Module 01 Challenges

1. Now that we've created an EC2 instance let's go ahead and create an api gateway resource and connect it to our ec2 instance (you will need to do some research on this and realize how to work with instance IDs)

2. Increase the count of EC2 instances from a single instance to a __count__ of three instances; in other words create a cluster of EC2 instances. Google is probably your friend here and you'll need to watch how you create everything.

3. Switch the AMIs being used to Ubuntu amis (you will need to google here to). Keep in mind that existing amis are __region specific__. How can you upgrade/downgrade versions of ec2 instance amis in real time? How can you access the latest? 

4. Re-edit all of the previous instances moving all hardcoded data into the **variables.tf** folder to turn this into a template.