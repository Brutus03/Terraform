# Security list
## LB
resource "oci_core_security_list" "LB_securitylist" {
  display_name   = "開発環境_LBセグメント"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"

  ingress_security_rules {
    source = "0.0.0.0/0"
    protocol = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "ALL"
    }
  }

## Web
resource "oci_core_security_list" "Web_securitylist" {
  display_name   = "開発環境_Webセグメント"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"

  ingress_security_rules {
    source = "10.0.0.0/24"
    protocol = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "ALL"
    }
  }

## DB
resource "oci_core_security_list" "DB_securitylist" {
  display_name   = "開発環境_DBセグメント"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"

  ingress_security_rules {
    source = "10.0.1.0/24"
    protocol = "6"
    tcp_options {
      min = 5432
      max = 5432
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "ALL"
    }
  }

## Security list Ope
resource "oci_core_security_list" "Ope_securitylist" {
  display_name   = "開発環境_運用セグメント"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn2.id}"

  ingress_security_rules {
    source = "192.168.1.0/24"
    protocol = "1"
  }

  ingress_security_rules {
    source = "x.x.x.x/32"
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    source = "192.168.1.0/24"
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "ALL"
    }
  }
