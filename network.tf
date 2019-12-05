# Virtual Cloud Network
## vcn1
resource "oci_core_virtual_network" "vcn1" {
   display_name = "vcn1"
   compartment_id = "${var.compartment_ocid}"
   cidr_block = "10.0.0.0/16"
   dns_label = "vcn1"
}

## vcn2
resource "oci_core_virtual_network" "vcn2" {
   display_name = "vcn2"
   compartment_id = "${var.compartment_ocid}"
   cidr_block = "192.168.0.0/16"
   dns_label = "vcn2"
}

# Subnet
## Subnet LB
resource "oci_core_subnet" "LB_Segment" {
  display_name        = "開発環境_LBセグメント"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"
  cidr_block          = "10.0.0.0/24"
  route_table_id      = "${oci_core_default_route_table.default-route-table1.id}"
  security_list_ids   = ["${oci_core_security_list.LB_securitylist.id}"]
}

## Subnet Web
resource "oci_core_subnet" "Web_Segment" {
  display_name        = "開発環境_WEBセグメント"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"
  cidr_block          = "10.0.1.0/24"
  route_table_id      = "${oci_core_default_route_table.default-route-table1.id}"
  security_list_ids   = ["${oci_core_security_list.Web_securitylist.id}"]
}

## Subnet DB
resource "oci_core_subnet" "DB_Segment" {
  display_name        = "開発環境_DBセグメント"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"
  cidr_block          = "10.0.2.0/24"
  route_table_id      = "${oci_core_route_table.nat-route-table.id}"
  prohibit_public_ip_on_vnic = "true"
  security_list_ids   = ["${oci_core_security_list.DB_securitylist.id}"]
}

## Subnet Operation
resource "oci_core_subnet" "Ope_Segment" {
  display_name        = "開発環境_運用セグメント"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn2.id}"
  cidr_block          = "192.168.1.0/24"
  route_table_id      = "${oci_core_default_route_table.default-route-table2.id}"
  security_list_ids   = ["${oci_core_security_list.Ope_securitylist.id}"]
}

# Route Table
## default-route-table1
resource "oci_core_default_route_table" "default-route-table1" {
  manage_default_resource_id = "${oci_core_virtual_network.vcn1.default_route_table_id}"

  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.internet-gateway1.id}"
  }
}

## nat-route-table
resource "oci_core_route_table" "nat-route-table" {
  display_name   = "nat-route-table"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"
  route_rules {
    destination        = "0.0.0.0/0"
    network_entity_id = "${oci_core_nat_gateway.nat-gateway.id}"
  }
}

## default-route-table2
resource "oci_core_default_route_table" "default-route-table2" {
  manage_default_resource_id = "${oci_core_virtual_network.vcn2.default_route_table_id}"

  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.internet-gateway2.id}"
  }
}

# Internet Gateway
## internet-gateway1
resource "oci_core_internet_gateway" "internet-gateway1" {
  display_name   = "internet-gateway1"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"
}

## internet-gateway2
resource "oci_core_internet_gateway" "internet-gateway2" {
  display_name   = "internet-gateway2"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn2.id}"
}

# Nat-Gateway
resource "oci_core_nat_gateway" "nat-gateway" {
  display_name   = "nat-gateway"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.vcn1.id}"
}
