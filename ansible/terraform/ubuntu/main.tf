
terraform{
  required_version = ">=1.1.6"
  required_providers {
      aws = {
      source = "hashicorp/aws"
      version = "~> 4.5"
      }
    }
}

provider "aws" {
  region = "ap-south-1"
  shared_credentials_file = "/var/lib/jenkins/files/credentials"
}



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


  provisioner "local-exec" {
    command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key /var/lib/jenkins/files/roshi.pem -i ${aws_instance.terraforminstance.public_ip}, terraform-ansible.yaml"

  }

}


#terraform init
#terraform plan
#terraform apply
