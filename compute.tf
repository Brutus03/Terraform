# Variable
variable "ImageOS" {
  default = "Oracle Linux"
}

variable "ImageOSVersion" {
  default = "7.7"
}

variable "instance_shape" {
  default = "VM.Standard.E2.1"
}

variable "fault_domain" {
  default = "FAULT-DOMAIN-1"
}

variable "ip_address1" {
  default = "192.168.1.2"
}

variable "ip_address2" {
  default = "192.168.1.3"
}

variable "ip_address3" {
  default = "10.0.1.2"
}

variable "ip_address4" {
  default = "10.0.1.3"
}

variable "ip_address5" {
  default = "192.168.1.4"
}

variable "ip_address6" {
  default = "10.0.2.2"
}

variable "ip_address7" {
  default = "192.168.1.5"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Gets a list of all Oracle Linux 7.7 images that support a given Instance shape
data "oci_core_images" "instance" {
  compartment_id           = "${var.tenancy_ocid}"
  operating_system         = "${var.ImageOS}"
  operating_system_version = "${var.ImageOSVersion}"
  shape                    = "${var.instance_shape}"
}

# Instance
## Compute Web-Server#1
resource "oci_core_instance" "instance1" {
  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.instance.images[0], "id")}"
  }

  display_name        = "Web-Server#1"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  shape               = "${var.instance_shape}"
  compartment_id      = "${var.compartment_ocid}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.Ope_Segment.id}"
    assign_public_ip = "true"
    private_ip       = "${var.ip_address1}"
  }

  metadata = {
        ssh_authorized_keys = "${var.ssh_public_key}"
        user_data           = "${base64encode(file("./userdata/cloud-init1.tpl"))}"
    }

  fault_domain        = "${var.fault_domain}"

  provisioner "remote-exec" {
    connection {
      host    = "${oci_core_instance.instance1.public_ip}"
      type    = "ssh"
      user    = "opc"
      agent   = "true"
      timeout = "3m"
    }

    inline = [
      "crontab -l | { cat; echo \"@reboot sudo /usr/local/bin/secondary_vnic_all_configure.sh -c\"; } | crontab -"
      ]
  }
}

### SecondaryVNIC Web-Server#1
resource "oci_core_vnic_attachment" "Web1_secondary_vnic_attachment" {
  create_vnic_details {
    display_name           = "SecondaryVNIC"
    subnet_id              = "${oci_core_subnet.Web_Segment.id}"
    assign_public_ip       = "true"
    private_ip             = "${var.ip_address3}"
    skip_source_dest_check = "false"
}

  instance_id = "${oci_core_instance.instance1.id}"

}

## Compute Web-Server#2
resource "oci_core_instance" "instance2" {
  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.instance.images[0], "id")}"
  }

  display_name        = "Web-Server#2"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  shape               = "${var.instance_shape}"
  compartment_id      = "${var.compartment_ocid}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.Ope_Segment.id}"
    assign_public_ip = "true"
    private_ip       = "${var.ip_address2}"
  }

  metadata = {
        ssh_authorized_keys = "${var.ssh_public_key}"
        user_data           = "${base64encode(file("./userdata/cloud-init1.tpl"))}"
    }

  fault_domain        = "${var.fault_domain}"

  provisioner "remote-exec" {
    connection {
      host    = "${oci_core_instance.instance2.public_ip}"
      type    = "ssh"
      user    = "opc"
      agent   = "true"
      timeout = "3m"
      }

    inline = [
      "crontab -l | { cat; echo \"@reboot sudo /usr/local/bin/secondary_vnic_all_configure.sh -c\"; } | crontab -"
      ]
  }
}

### SecondaryVNIC Web-Server#2
resource "oci_core_vnic_attachment" "Web2_secondary_vnic_attachment" {
  create_vnic_details {
    display_name           = "SecondaryVNIC"
    subnet_id              = "${oci_core_subnet.Web_Segment.id}"
    assign_public_ip       = "true"
    private_ip             = "${var.ip_address4}"
    skip_source_dest_check = "false"
}

  instance_id = "${oci_core_instance.instance2.id}"

}

## Compute DB-Server
resource "oci_core_instance" "instance3" {
  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.instance.images[0], "id")}"
  }

  display_name        = "DB-Server"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  shape               = "${var.instance_shape}"
  compartment_id      = "${var.compartment_ocid}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.Ope_Segment.id}"
    private_ip       = "${var.ip_address5}"
  }

  metadata = {
        ssh_authorized_keys = "${var.ssh_public_key}"
        user_data           = "${base64encode(file("./userdata/cloud-init2.tpl"))}"
    }

  fault_domain        = "${var.fault_domain}"

  provisioner "remote-exec" {
    connection {
      host    = "${oci_core_instance.instance3.public_ip}"
      type    = "ssh"
      user    = "opc"
      agent   = "true"
      timeout = "3m"
      }

    inline = [
      "crontab -l | { cat; echo \"@reboot sudo /usr/local/bin/secondary_vnic_all_configure.sh -c\"; } | crontab -"
      ]
  }
}

### SecondaryVNIC DB-Server
resource "oci_core_vnic_attachment" "DB_secondary_vnic_attachment" {
  create_vnic_details {
    display_name = "SecondaryVNIC"
    subnet_id  = "${oci_core_subnet.DB_Segment.id}"
    assign_public_ip = false
    private_ip = "${var.ip_address6}"
    skip_source_dest_check = "false"
}

  instance_id = "${oci_core_instance.instance3.id}"

}

## Compute Operation-Server
resource "oci_core_instance" "instance4" {
  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.instance.images[0], "id")}"
  }

  display_name        = " Operation-Server"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  shape               = "${var.instance_shape}"
  compartment_id      = "${var.compartment_ocid}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.Ope_Segment.id}"
    private_ip       = "${var.ip_address7}"
  }

  metadata = {
        ssh_authorized_keys = "${var.ssh_public_key}"
        user_data           = "${base64encode(file("./userdata/cloud-init1.tpl"))}"
    }

  fault_domain        = "${var.fault_domain}"

  provisioner "remote-exec" {
    connection {
      host = "${oci_core_instance.instance3.public_ip}"
      type    = "ssh"
      user    = "opc"
      agent   = "true"
      timeout = "3m"
      }

    inline = [
      "crontab -l | { cat; echo \"@reboot sudo /usr/local/bin/secondary_vnic_all_configure.sh -c\"; } | crontab -"
      ]
  }
}
