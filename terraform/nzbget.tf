resource "vsphere_virtual_machine" "nzbget" {
  name             = "nzbget"
  resource_pool_id = "${vsphere_compute_cluster.dmarby_cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.esxi2.id}"

  num_cpus = 8
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.ubuntu-18_04.guest_id}"

  network_interface {
    network_id   = "${data.vsphere_network.vpn.id}"
    adapter_type = "${data.vsphere_virtual_machine.ubuntu-18_04.network_interface_types[0]}"
  }

  disk {
    label = "disk0"
    size  = 10
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.ubuntu-18_04.id}"

    customize {
      network_interface {}

      linux_options {
        host_name = "nzbget"
        domain    = "home.dmarby.se"
      }
    }
  }

  # Prevent terraform from recreating VMs when we update the template
  lifecycle {
    ignore_changes = ["clone.0.template_uuid", "disk.0"]
  }
}
