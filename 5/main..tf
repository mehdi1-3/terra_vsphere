terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.4.0"
    }
  }
}
provider "vsphere" {
  user           = "root"
  password       = "PfeActia2023"
  vsphere_server = "exsi.local.tn:443"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "dc1"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "esxi1/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_host" "h1" {
  name          = "esxi.local.tn"
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_host_virtual_switch" "hvs1" {
  name             = "dc_HPG0"
  host_system_id   = data.vsphere_host.h1.id
  network_adapters = ["vmnic3", "vmnic4"]
  active_nics      = ["vmnic3"]
  standby_nics     = ["vmnic4"]
}


resource "vsphere_host_port_group" "p1" {
  name                = "my-pg"
  virtual_switch_name = vsphere_host_virtual_switch.hvs1.name
  host_system_id      = data.vsphere_host.h1.id
}

resource "vsphere_vnic" "v1" {
  host      = data.vsphere_host.h1.id
  portgroup = vsphere_host_port_group.p1.name
  ipv4 {
    dhcp = false
    ip = "172.20.10.13"
    netmask ="255.255.255.240"
    gw ="172.20.10.1"
  }
  #enabled_services = ["vsan", "management"]
}

resource "vsphere_virtual_machine" "vm" {
  name             = "Ubuntu-OS-ip"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 1
  memory   = 1024
  guest_id = "ubuntu64Guest"

  ignored_guest_ips = []



  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }



  disk {
    label = "disk0"
    size = 10
  }

  cdrom {
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    path         = "os/ubuntu-18.04-server-amd64.iso"

  }
}