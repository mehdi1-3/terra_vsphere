terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.4.0"
    }
  }
}
##################################################################
# Provider
##################################################################
provider "vsphere" {
  user           = "root"
  password       = "PfeActia2023"
  vsphere_server = "192.168.1.128"
  # If you have a self-signed cert
  allow_unverified_ssl = true
}
 
##################################################################
# Variable
##################################################################
variable "instance_count" {
  default = 1 # Number of hosts to deploy
}
 
##################################################################
# Data
##################################################################
data "vsphere_datacenter" "datacenter" {
  name = "dc1"
}
 
data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
 

 

data "vsphere_resource_pool" "pool" {
  name          = "esxi1/Resources"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}
 
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
 
data "vsphere_host" "host" {
  name          = "exsi.local.tn"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
 
data "vsphere_ovf_vm_template" "ovf" {
  name              = "Ubuntu"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = "C:\\Users\\Mehdi MOSBAH\\Documents\\ovf\\Ubuntu.ovf"
  disk_provisioning = "thin"
  deployment_option = "" 
  ip_protocol       = "IPv4"
  ovf_network_map   = {
    "Network 1" = data.vsphere_network.network.id
  }
}
 
##################################################################
# Resource
##################################################################  
resource "vsphere_virtual_machine" "vm" {
  count            = var.instance_count
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  name             = "vm2"
  num_cpus         = data.vsphere_ovf_vm_template.ovf.num_cpus
  memory           = data.vsphere_ovf_vm_template.ovf.memory
  guest_id         = data.vsphere_ovf_vm_template.ovf.guest_id
  resource_pool_id = data.vsphere_ovf_vm_template.ovf.resource_pool_id
  datastore_id     = data.vsphere_ovf_vm_template.ovf.datastore_id
  host_system_id   = data.vsphere_ovf_vm_template.ovf.host_system_id
 
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
 
  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovf.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }
 
  ovf_deploy {
    local_ovf_path    = data.vsphere_ovf_vm_template.ovf.local_ovf_path
    disk_provisioning = data.vsphere_ovf_vm_template.ovf.disk_provisioning
    deployment_option = data.vsphere_ovf_vm_template.ovf.deployment_option
    ip_protocol       = data.vsphere_ovf_vm_template.ovf.ip_protocol
    ovf_network_map   = data.vsphere_ovf_vm_template.ovf.ovf_network_map
  }
 
  vapp {
    properties = {
      "preferipv6" = "False"
      "rootpw"     = "VMware1!"
      "ip0"        = "192.168.1.199"
      "netmask0"   = "255.255.255.0"
      "gateway"    = "192.168.1.1"
      "searchpath" = "exsi.local.tn"
      "hostname"   = "vm2.tn"
      "domain"     = "exsi.local.tn"
      "sshkey"     = ""
      "DNS"        = "192.168.1.1"
      "fips"       = "False"
    }
  }
  lifecycle {
    ignore_changes = [
      annotation,
      disk[0].io_share_count,
      disk[1].io_share_count,
      disk[2].io_share_count,
      vapp[0].properties,
    ]
  }
}