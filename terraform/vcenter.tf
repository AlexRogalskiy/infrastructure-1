provider "vsphere" {
  user           = "${var.vcenter_user}"
  password       = "${var.vcenter_password}"
  vsphere_server = "${var.vcenter_host}"

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
  count         = "${length(var.hosts)}"
  name          = "${var.hosts[count.index]}"
  datacenter_id = "${data.vsphere_datacenter.dmarby.id}"
}

# Configure the cluster
resource "vsphere_compute_cluster" "dmarby_cluster" {
  name            = "dmarby"
  datacenter_id   = "${data.vsphere_datacenter.dmarby.id}"
  host_system_ids = ["${data.vsphere_host.hosts.*.id}"]

  drs_enabled = false

  # drs_automation_level = "fullyAutomated"
  ha_enabled = false
}

# Configure the distributed switch

variable "network_interfaces" {
  default = [
    "vmnic0",
    "vmnic1",
  ]
}

resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = "dvs"
  datacenter_id = "${data.vsphere_datacenter.dmarby.id}"

  network_resource_control_enabled = true

  uplinks         = ["uplink1", "uplink2"]
  active_uplinks  = ["uplink1"]
  standby_uplinks = []

  host {
    host_system_id = "${data.vsphere_host.hosts.0.id}"
    devices        = ["${var.network_interfaces}"]
  }

  host {
    host_system_id = "${data.vsphere_host.hosts.1.id}"
    devices        = ["${var.network_interfaces}"]
  }
}

# Configure portgroups for the distributed switch
resource "vsphere_distributed_port_group" "management" {
  name                            = "Management Network"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id                         = 0
}

resource "vsphere_distributed_port_group" "vm" {
  name                            = "VM"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id                         = 0
}

resource "vsphere_distributed_port_group" "vpn" {
  name                            = "VPN"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id                         = 20
}

resource "vsphere_distributed_port_group" "wan" {
  name                            = "WAN"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"
  vlan_id                         = 5
}

resource "vsphere_distributed_port_group" "lan" {
  name                            = "LAN"
  distributed_virtual_switch_uuid = "${vsphere_distributed_virtual_switch.dvs.id}"

  vlan_range {
    min_vlan = 0    # Trunk everything
    max_vlan = 4094
  }
}

# Register common resources used to create VMs
data "vsphere_datastore" "esxi" {
  name          = "esxi"
  datacenter_id = "${data.vsphere_datacenter.dmarby.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "dmarby/Resources"
  datacenter_id = "${data.vsphere_datacenter.dmarby.id}"
}

data "vsphere_network" "vm" {
  name          = "VM"
  datacenter_id = "${data.vsphere_datacenter.dmarby.id}"
}

data "vsphere_virtual_machine" "ubuntu-18_04" {
  name          = "ubuntu-18.04"
  datacenter_id = "${data.vsphere_datacenter.dmarby.id}"
}
