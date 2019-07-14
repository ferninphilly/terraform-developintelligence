# Lab Four

## Managing your terraform infrastructure

This lab and module will focus mainly on the best ways to manage your terraform infrastructure. I want to emphasize some tips and tricks that have worked for me in the past. This lab will, out of necessity, be less "hands on" and focus more on lecture/discussion about best practices around keeping your infrastructure-as-code in general and terraform specifically.

### Backend Configuration

1. If you've been paying attention to your directories you've probably noticed that you are getting a couple of files created with `terraform init`...specifically things like `terraform.tfstate` and `terraform.tfstate.backup`. Opening these you'll see that it's a basic JSON representation of the current state of your terraform infrastructure. Here's the issue: __currently it only exists locally to your host computer__

2. So imagine, if you will, you have a terraform infrastructure that is being worked on by multiple people- each of whom is creating and destroying different resources in your AWS account all the time. You can see where this would be (could be) a serious issue... so we need to worry about how to manage it if YOUR particular terraform state is out of whack with what another member of your team's state might be.

3. To solve for this we can create a bucket that is kept remotely that keeps the current "state" of the infrastructure in it at all times! If we give everyone on our team access to said bucket then they can use it to update their __local__ terraform state to the current terraform state of the infrastructure! __and just like that we can create these terraform structures in teams__!

4. So let's do that now! We will have to do this in two steps in order for it to be effective:
    * Create an s3 Bucket in which to store our state and 
    * Set terraform to set our **tfstate** files up to said bucket.

5. So- to start out with let's create our s3 bucket. NOW- the issue here is that we can't create this s3 bucket **with** our terraform files as terraform backup locations are specified as soon as you `terraform init`...so hopefully you see the issue with trying to create a bucket and simultaneously use that bucket to store your initialization files. INSTEAD we'll go to the AWS management console and create a simple bucket (not worrying about security at this point):



