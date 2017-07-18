# Build a highly available webserver cluster on AWS
### Using Terraform, Ansible and AWS

#### Prerequisites
Terraform 0.9.6 (may work on others)
Ansible 2.2.1.0 (may work on others)
AWS SSH keypair created and private part loader in local keychain.

1. Create a file call secrets in the root of this repo, the file should contain the below. Ensure to change AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to your own. Leave AWS_DEFAULT_REGION as is.

> export AWS_ACCESS_KEY_ID="xxxxxxxxxx"
> export AWS_SECRET_ACCESS_KEY="xxxxxxxxxx"
> export AWS_DEFAULT_REGION="eu-west-1"

2. Ensure you have create a keypair within your AWS account. Note the name for the keypair, in my case this is glangford.

3. Within the terraform folder edit the terraform.tfvars file. You should set account_id to that of your AWS account id (it is used for the instance profile so we only give privs to instances for the correct ELB). Replace vpc_id with the VPC id from your account. Replace the subnet id's for subnet-eu-west-1a, subnet-eu-west-1b, subnet-eu-west-1c with those from your AWS account. You can find these within Subnets under VPC, ensure the subnets ids are the ones associated with the VPC id you entered. Now save the file.

4. Now run the following command without quotes from the root of the respository "source secrets" this will set the environment variables for your AWS access keys which terraform will use to authenticate to the AWS api.

5. You are now ready to build the infrastucture using terraform. From within the terraform folder, run the following command without quotes "terraform plan" you should be advised by the output that there are 7 changes to add, 0 to change and 0 to destroy. If you are happy you can now run the following without quotes "terraform apply". There is a very good chance that this command will fail the first time, this is due to the instance profile creation not completing before terraform wants to create the instance, if you do get a failure run "terraform apply" again. You can find a bug for this issue on Github https://github.com/hashicorp/terraform/issues/15341
Once you have succesfully run "terraform apply" you should see some outputs in green (depending on your terminal), pay special attention to "elb_hostname", "public-ip-web-1" and "public-ip-web-2" these are going to be used in future steps so save them somewhere safe.

6. At this point you should have two instances and an ELB running in your account. Nothing will be served by the ELB yet as the web nodes have not been configured. Within a new terminal change into the ansible directory within the root of this respository. You will see a file called inventory, open this file and replace the IP adresses under [webserver-nodes] with the ip addresses from the terraform output. If the IP address from terraform was 10.10.10.10 for web1 the line should look like web-1 ansible_ssh_host=10.10.10.10 do this for both web-1 and web-2. Instead of manually editing the file it is possible to use a dynamic inventory script instead, this could lookup the instances via the AWS API using their known tags. Or we could even do some service discovery using a tool like etcd or consul, terraform can talk directly to consul which is quite useful if you went down that route.

7. Now before we can run ansible you must ensure that the private part of the keypair which you created or already had within the AWS console is loaded in your SSH keychain. You could test this by trying to ssh to the host in advance of running ansible. e.g ssh ubuntu@10.10.10.10 if the keypair is setup correctly you should be logged into the instance, now you can type exit and quit.

8. We are now ready to provision the web servers. From within the ansible directory you must run the following command without quotes "ansible-playbook -i ./inventory provision.yml" after some minutes you should see ansible complete it's run. Good stuff, we have just installed python, awscli, apache and our application (some basic webpage) also during that process awscli has been run to register the instance to the ELB load balancer. The magic here is the instance profile. When terraform ran we created an instance profile which defined that these instances should be able to register and deregister themselves to the load balancer.

10. If all the above steps have completed correctly you should now be able to visit the load balancer address from the terraform output in your browser. e.g http://elb-web-balancer-11111111.eu-west-1.elb.amazonaws.com you should see the text "Hello World! - " followed by the IP address of the node you are hitting. If you refresh you should notice that on each refresh you are directed to a differnt node. In a real world application however you would probably session afinity so that you stay connected to the same server for each request. There are cases where you could have a shared cookie store between web nodes so this would not matter as much.

Congratulations you have built yourself some infrastucture with terraform and provisioned it with ansible. Unless you would like your bill to grow it's probably now time to destroy the infrastucture. From within the terraform folder run terraform destroy -force this will kill everything we created through terraform.

#### Improvements
There are ways we could improve this example. One way would be to bake an AMI with a cloud-config script that can provision the instance and add it into a load balancer. This way we could create an autoscaling group and not worry about having to run ansible each time a new node comes online. This would also make the solution scaleable as extra web nodes could be bought online quickly.

We might also consider using remote state so that multiple developers could work on this at the same time.
