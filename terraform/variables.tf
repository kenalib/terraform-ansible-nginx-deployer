variable "short_name"                   { default = "my-webapp" }
variable "role"                         { default = "dev" }
variable "availability_zone"            { default = "ap-northeast-1a" }

variable "image_id"                     { default = "centos_7_03_64_40G_alibase_20170625.vhd" }
variable "nic_type"                     { default = "intranet" }

variable "internet_charge_type"         { default = "PayByTraffic" }
variable "internet_max_bandwidth_out"   { default = 1 }

variable "key_name"                     { default = "tf_keypair_jp" }
variable "private_key_file"             { default = "tf_keypair_jp.pem" }
