terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.3.1"
    }
  }
}
# Define authentification configuration
provider "vsphere" {
  # If you use a domain set your login like this "Domain\\User"
  user           = "root"
  password       = "PfeActia2023"
  vsphere_server = "exsi.local.tn"

  # If you have a self-signed cert
  allow_unverified_ssl = true

}

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "datacenter" {
  name = "dc-01"

}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_compute_cluster" "cluster" {
  name          = "	exsi.local.tn"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "foo"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 1
  memory           = 1024
  guest_id         = "other3xLinux64Guest"
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label = "disk0"
    size  = 3
  }
}