# Configure the datacenter
resource "vsphere_datacenter" "apartment" {
  name = "apartment"
}

data "vsphere_datacenter" "apartment" {
  name = "apartment"
}

# Register ESXI hosts
variable "apartment_hosts" {
  default = [
    "esxi-apartment.home.dmarby.se",
  ]
}

data "vsphere_host" "apartment_hosts" {
  count         = length(var.apartment_hosts)
  name          = var.apartment_hosts[count.index]
  datacenter_id = data.vsphere_datacenter.apartment.id
}

# Configure the cluster
resource "vsphere_compute_cluster" "apartment_cluster" {
  name            = "apartment"
  datacenter_id   = data.vsphere_datacenter.apartment.id
  host_system_ids = data.vsphere_host.apartment_hosts.*.id

  # Manual DRS until we have vSAN
  drs_enabled          = true
  drs_automation_level = "manual"

  # Disable power management
  dpm_enabled          = false
  dpm_automation_level = "manual"

  ha_enabled = false
}

# Configure the distributed switch
variable "apartment_network_interfaces" {
  default = [
    "vmnic0",
    "vmnic2",
  ]
}

resource "vsphere_distributed_virtual_switch" "apartment_dvs" {
  name          = "apartment-dvs"
  datacenter_id = data.vsphere_datacenter.apartment.id
  network_resource_control_enabled = true
  uplinks         = ["uplink1", "uplink2"]
  active_uplinks  = ["uplink1"] # TODO: Change?
  standby_uplinks = ["uplink2"]
  host {
    host_system_id = data.vsphere_host.apartment_hosts.0.id
    devices        = var.apartment_network_interfaces
  }
}

# Configure portgroups for the distributed switch
resource "vsphere_distributed_port_group" "apartment_management" {
  name                            = "Management Network"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.apartment_dvs.id
  vlan_id                         = 100
}
resource "vsphere_distributed_port_group" "apartment_servers" {
  name                            = "SERVERS"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.apartment_dvs.id
  vlan_id                         = 20
}
resource "vsphere_distributed_port_group" "apartment_lan" {
  name                            = "LAN"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.apartment_dvs.id
  vlan_range {
    min_vlan = 0    # Trunk everything
    max_vlan = 4094
  }
}

# DVS for WAN
# Configure the distributed switch
variable "apartment_network_wan_interfaces" {
  default = [
    "vmnic1",
  ]
}

resource "vsphere_distributed_virtual_switch" "apartment_wan_dvs" {
  name          = "apartment-wan-dvs"
  datacenter_id = data.vsphere_datacenter.apartment.id
  network_resource_control_enabled = true
  uplinks         = ["uplink1"]
  active_uplinks  = ["uplink1"]
  host {
    host_system_id = data.vsphere_host.apartment_hosts.0.id
    devices        = var.apartment_network_wan_interfaces
  }
}

resource "vsphere_distributed_port_group" "apartment_dedicated_wan" {
  name                            = "WAN"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.apartment_wan_dvs.id
}

# Register common resources used to create VMs
# Datastores
data "vsphere_datastore" "esxi-apartment" {
  name          = "esxi-apartment"
  datacenter_id = data.vsphere_datacenter.apartment.id
}
