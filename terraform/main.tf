resource "alicloud_vpc" "vpc" {
  name              = "vpc-${var.short_name}"
  cidr_block        = "10.1.0.0/21"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.availability_zone}"
}

resource "alicloud_security_group" "sg" {
  name              = "sg-${var.short_name}"
  vpc_id            = "${alicloud_vpc.vpc.id}"
}

resource "alicloud_security_group_rule" "allow_ssh_22" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "${var.nic_type}"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_http_80" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "${var.nic_type}"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_https_443" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "${var.nic_type}"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

data "alicloud_instance_types" "instance_type" {
  instance_type_family  = "ecs.n4"
  cpu_core_count        = "1"
  memory_size           = "2"
}

resource "alicloud_key_pair" "key_pair" {
  key_name = "${var.key_name}"
  key_file = "${var.private_key_file}"
}

resource "alicloud_instance" "instance" {
  instance_name         = "${var.short_name}-${var.role}"
  host_name             = "${var.short_name}-${var.role}"
  availability_zone     = "${var.availability_zone}"

  image_id              = "${var.image_id}"
  instance_type         = "${data.alicloud_instance_types.instance_type.instance_types.0.id}"

  security_groups       = ["${alicloud_security_group.sg.*.id}"]
  vswitch_id            = "${alicloud_vswitch.vsw.id}"

  internet_charge_type  = "${var.internet_charge_type}"
  internet_max_bandwidth_out = "${var.internet_max_bandwidth_out}"

  key_name              = "${alicloud_key_pair.key_pair.id}"

  tags {
    role = "${var.role}"
  }

  connection {
    type        = "ssh"
    host        = "${self.public_ip}"
    user        = "root"
    private_key = "${file("./${var.private_key_file}")}"
    timeout     = "20s"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'This is sample remote-exec provisioner.' >> /tmp/sample.txt"
    ]
  }
}
