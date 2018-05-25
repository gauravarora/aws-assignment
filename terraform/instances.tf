variable "aws_key_name" {}
variable "admin_password" {}

data "template_file" "userdata_linux" {
    template = "${file("data/userdata-linux.sh")}"
}

data "aws_ami" "amazon_windows_2012R2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
}

resource "aws_instance" "windows" {
    ami                         = "${data.aws_ami.amazon_windows_2012R2.image_id}"
    availability_zone           = "ap-southeast-1b"
    instance_type               = "t2.micro"
    key_name                    = "${var.aws_key_name}"
    vpc_security_group_ids      = ["${aws_security_group.ssh.id}", "${module.http_80.this_security_group_id}", "${module.outgoing.this_security_group_id}", "${module.rdp.this_security_group_id}", "${module.winrm.this_security_group_id}"]
    subnet_id                   = "${aws_subnet.public_1b.id}"
    associate_public_ip_address = true
    source_dest_check           = false
    user_data                   = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5986 remoteip=any localip=any action=allow
# Bring ebs volume online with read-write access
Get-Disk | Where-Object IsOffline -Eq $True | Set-Disk -IsOffline $False
Get-Disk | Where-Object isReadOnly -Eq $True | Set-Disk -IsReadOnly $False
# Set Administrator password
$admin = [adsi]("WinNT://./Administrator, user")
$admin.psbase.invoke("SetPassword", "${var.admin_password}")
</powershell>
EOF

    connection {
        type        = "winrm"
        user        = "Administrator"
        password    = "${var.admin_password}"
    }
    root_block_device {
        volume_type = "gp2"
        volume_size = 30
    }
    ebs_block_device = [{
        device_name = "xvdj"
        volume_type = "gp2"
        volume_size = 1
    }]
    tags {
        Name = "aws-assignment-windows"
    }
}
resource "aws_instance" "linux" {
	ami                         = "ami-d62014aa"
	availability_zone           = "ap-southeast-1a"
	instance_type               = "t2.micro"
	key_name                    = "${var.aws_key_name}"
	vpc_security_group_ids      = ["${aws_security_group.ssh.id}", "${module.http_80.this_security_group_id}", "${module.outgoing.this_security_group_id}"]
	subnet_id                   = "${aws_subnet.public_1a.id}"
	associate_public_ip_address = true
	source_dest_check           = false
	user_data                   = "${data.template_file.userdata_linux.rendered}"

	tags {
		Name = "aws-assignment-linux"
	}
    root_block_device {
        volume_type = "gp2"
        volume_size = 16
    }
    ebs_block_device {
        device_name = "/dev/xvdh"
        volume_type = "gp2"
        volume_size = 1
    }
}

resource "aws_eip" "linux" {
	vpc         = true
	instance    = "${aws_instance.linux.id}"
}

resource "aws_eip" "windows" {
    vpc = true
    instance = "${aws_instance.windows.id}"
}

output "linux_ip" {
	value = "${aws_eip.linux.public_ip}"
}

output "windows_ip" {
    value = "${aws_eip.windows.public_ip}"
}
