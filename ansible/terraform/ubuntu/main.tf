
terraform{
  required_version = ">=1.1.6"
  required_providers {
      aws = {
      source = "hashicorp/aws"
      version = "~> 4.5"
      }
    }
}
# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
  shared_credentials_file = "/var/lib/jenkins/files/credentials"
}

#create free ec2 instance using terraform
#steps in terminal
#do terraform init
#terraform plan
#terraform apply

resource "aws_instance" "terraforminstance" {
  
  ami           = "ami-0f69bc5520884278e" #ubuntu server
  instance_type = "t2.micro"
  key_name = "roshi" #imp to provide key pair
  #key pair is from aws->ec2->keypairs
  availability_zone = "ap-south-1b"
  security_groups = ["Security-Ansible2"]
  #created new security groups for ec2 instance in aws
   tags = {
    Name = "UbuntuAnsibleTerraformEC2"
  }

  #provisioners in terraform are used to execute
  #the scripts on remote machines which can be
  #resource creation or destruction
#the local-exec provisioner requires no other
#configurations, it will directly connect to remote machines

  provisioner "local-exec" {
    command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key /var/lib/jenkins/files/roshi.pem -i ${aws_instance.terraforminstance.public_ip}, terraform-ansible.yaml"
#sleep for 120 seconds so that 2/2 checks get enabled
#skip checking the key
#telling ansible to connect to pem file
#-i ${aws_instance.terraforminstance.public_ip} using the current ip address of the server as inventory file
#and then run the playbook  
  }

}

#then move to terminal in terraform folder directory
#terraform init
#terraform plan
#terraform apply
