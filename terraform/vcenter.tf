provider "vsphere" {
  version = "~> 1.12"

  user           = var.vcenter_user
  password       = var.vcenter_password
  vsphere_server = var.vcenter_host

  allow_unverified_ssl = true
}

# Configure the datacenter
resource "vsphere_datacenter" "dmarby" {
  name = "dmarby"
}

data "vsphere_datacenter" "dmarby" {
  name = "dmarby"
}

# Register ESXI hosts
variable "hosts" {
  default = [
    "esxi1.home.dmarby.se",
    "esxi2.home.dmarby.se",
  ]
}

data "vsphere_host" "hosts" {
  count         = length(var.hosts)
  name          = var.hosts[count.index]
  datacenter_id = data.vsphere_datacenter.dmarby.id
}

# Configure the cluster
resource "vsphere_compute_cluster" "dmarby_cluster" {
  name            = "dmarby"
  datacenter_id   = data.vsphere_datacenter.dmarby.id
  host_system_ids = data.vsphere_host.hosts.*.id

  # Manual DRS until we have vSAN
  drs_enabled          = true
  drs_automation_level = "manual"

  # Disable power management
  dpm_enabled          = false
  dpm_automation_level = "manual"

  ha_enabled = false
}

# Configure the distributed switch

variable "network_interfaces" {
  default = [
    "vmnic1000202",
    "vmnic2",
  ]
}

resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = "dvs"
  datacenter_id = data.vsphere_datacenter.dmarby.id

  network_resource_control_enabled = true

  uplinks         = ["uplink1", "uplink2"]
  active_uplinks  = ["uplink1"] # TODO: One standby? IDK?
  standby_uplinks = ["uplink2"]

  host {
    host_system_id = data.vsphere_host.hosts[0].id
    devices        = var.network_interfaces
  }

  host {
    host_system_id = data.vsphere_host.hosts[1].id
    devices        = var.network_interfaces
  }
}

# TODO: Make sure this configures one uplink as active one as standby or w/e it should be

# Configure portgroups for the distributed switch
resource "vsphere_distributed_port_group" "management" {
  name                            = "Management Network"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = 100
}

resource "vsphere_distributed_port_group" "servers" {
  name                            = "SERVERS"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = 20
}

resource "vsphere_distributed_port_group" "wan" {
  name                            = "WAN"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = 5
}

resource "vsphere_distributed_port_group" "lan" {
  name                            = "LAN"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.dvs.id

  vlan_range {
    min_vlan = 0 # Trunk everything
    max_vlan = 4094
  }
}

# Register common resources used to create VMs
# Datastores
data "vsphere_datastore" "esxi1" {
  name          = "esxi1"
  datacenter_id = data.vsphere_datacenter.dmarby.id
}

data "vsphere_datastore" "esxi2" {
  name          = "esxi2"
  datacenter_id = data.vsphere_datacenter.dmarby.id
}

# Templates
data "vsphere_virtual_machine" "ubuntu-18_04" {
  name          = "ubuntu-18.04"
  datacenter_id = data.vsphere_datacenter.dmarby.id
}

data "vsphere_virtual_machine" "vyos-1_2" {
  name          = "vyos-1.2"
  datacenter_id = data.vsphere_datacenter.dmarby.id
}

# Tags
resource "vsphere_tag_category" "type" {
  name        = "type"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "vyos" {
  name        = "vyos"
  category_id = vsphere_tag_category.type.id
  description = "Managed by Terraform"
}

resource "vsphere_tag" "ns" {
  name        = "ns"
  category_id = vsphere_tag_category.type.id
  description = "Managed by Terraform"
}

resource "vsphere_tag" "unifi" {
  name        = "unifi"
  category_id = vsphere_tag_category.type.id
  description = "Managed by Terraform"
}

resource "vsphere_tag" "backup" {
  name        = "backup"
  category_id = vsphere_tag_category.type.id
  description = "Managed by Terraform"
}

resource "vsphere_tag" "homebridge" {
  name        = "homebridge"
  category_id = vsphere_tag_category.type.id
  description = "Managed by Terraform"
}
