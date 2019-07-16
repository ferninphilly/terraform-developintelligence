# Module 03 Challenges

1. Let's create a serverless app! Using the **aws_internet_gateway** and your **aws_lambda_function**- put them into modules and organize them to use your **myql_rds** that we created in the last challenge.

2. Provision a **jenkins** server on a **ubuntu** instance ami. Open it up to take code and provide the  necessary CI/CD builds. Add in the appropriate READMEs to the module so that we have a __jenkins server__ module that can be reused.

3. Move your **environment_tags** from the low level modules to a single, centralized location which will populate all of environment tags in the submodules. Can you see a way to use an **environment variable** to populate these tags? (hint- google this one and take a look at how  terraform can  use environment variables to populate vars)

4. Using **data sources** from your already deployed vpc- go ahead and add your **aws_lambda_function** and **rds** into that vpc. 

5. Push your modules to a repository for others to share. Create and provision EC2 instances that would be useful in your own day to day work.