data "vsphere_virtual_machine" "eaton_ipm" {
  name          = "eaton-ipm-template"
  datacenter_id = data.vsphere_datacenter.dmarby.id
}

resource "vsphere_virtual_machine" "eaton-ipm" {
  name             = "eaton-ipm"
  resource_pool_id = vsphere_compute_cluster.dmarby_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.esxi1.id

  num_cpus = 2
  memory   = 2048
  guest_id = data.vsphere_virtual_machine.eaton_ipm.guest_id

  network_interface {
    network_id     = vsphere_distributed_port_group.servers.id
    use_static_mac = true
    mac_address    = "00:50:56:a7:40:a9"
  }

  disk {
    label = "disk0"
    size  = 10
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.eaton_ipm.id
  }
  # Prevent terraform from recreating VMs when we update the template
  lifecycle {
    ignore_changes = [clone.0.template_uuid, disk.0, annotation]
  }
}

