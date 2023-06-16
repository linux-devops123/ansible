/*the main idea i have created here is 
creating 3 windows instance and then converting the
tpl (template file) into ini file 
and then run the ansible+terraform cmd
*/
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
  shared_credentials_files = ["/var/lib/jenkins/files/credentials"]
   
}


resource "aws_instance" "windowsinstance" {
  count         = 2      # will create 2 instances
  ami           = var.ami
  instance_type = var.instance_type
  availability_zone = var.availability_zone
   tags = {
    Name = "WindowsAnsibleEC2"
  }
  security_groups = ["securitygroup-windows-ansible","Security-Ansible2"]
  key_name = "roshi"
  user_data= <<-EOF
<powershell>
netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "Roshi123!!!")

$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file 
</powershell>
  EOF
  
}
resource "local_file" "inventory"{
  content = templatefile("inventory.tpl",{
    x = "${aws_instance.windowsinstance.*.public_ip}"
  })
  filename = "hosts.ini"
}

resource "null_resource" "provisioner"{
  provisioner "local-exec" {
   /*
    command = "sleep 120;cp inventory.ini hosts.ini; sed -e  's/PUBLICIP1/element('${self.public_ip}',0)/g' -e 's/PUBLICIP2/element('${self.public_ip}',1)/g' -e 's/PUBLICIP3/element('${self.public_ip}',2)/g' hosts.ini;ansible-playbook -i hosts.ini installsoftware.yaml"
   
   command = "sleep 120;cp inventory.ini hosts.ini; sed -i  's/PUBLICIP1/${element("${aws_instance.windowsinstance.*.public_ip}[0]",0)}/g' hosts.ini;ansible-playbook -i hosts.ini installsoftware.yaml"
  
  command = "sleep 120;cp inventory.ini hosts.ini; sed -i  's/PUBLICIP1/${aws_instance.windowsinstance.*.public_ip[count.index][0]}/g' hosts.ini;ansible-playbook -i hosts.ini installsoftware.yaml"
  */
  command = "sleep 120;ansible-playbook -i hosts.ini installsoftware.yaml"
  }

}
#into the command
#hosts.ini is made while terraform apply
#sed command in linux performs replacement
#into the newly created hosts.ini, it replaces public ip with host ip address in file
# /s is substitution
# /g is global replacement
#see -https://geeksforgeeks.org/sed-command-in-linux-unix-with-examples/
output "id"{
  value =  element("${aws_instance.windowsinstance.*.public_ip}",0)
  #value =  ["${aws_instance.windowsinstance.*.public_ip}"]
  
}
#sleep for 3 minutes so that 2/2 checks get enabled 
#and we are able to push the ansible script for windows connection
#and then run the ansible playbook

#steps in terminal
#do terraform init

#terraform apply
#login credential
#username= administrator
#password= Roshi123!!!


#ansible playbook containing notepad++ and sql server got installed
