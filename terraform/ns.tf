resource "vsphere_virtual_machine" "ns" {
  name             = "ns"
  resource_pool_id = "${vsphere_compute_cluster.dmarby_cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.esxi1.id}"

  num_cpus = 1
  memory   = 512
  guest_id = "${data.vsphere_virtual_machine.ubuntu-18_04.guest_id}"

  network_interface {
    network_id   = "${vsphere_distributed_port_group.servers.id}"
    adapter_type = "${data.vsphere_virtual_machine.ubuntu-18_04.network_interface_types[0]}"
    use_static_mac = true
    mac_address    = "00:50:56:a7:40:a7"
  }

  disk {
    label = "disk0"
    size  = 10
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.ubuntu-18_04.id}"

    customize {
      network_interface {
        ipv4_address = "10.100.20.11"
        ipv4_netmask = 24
      }

      ipv4_gateway = "10.100.20.1"
      dns_server_list = ["10.100.20.1"]
      dns_suffix_list = ["home.dmarby.se"]

      linux_options {
        host_name = "ns"
        domain    = "home.dmarby.se"
      }
    }
  }

  # Prevent terraform from recreating VMs when we update the template
  lifecycle {
    ignore_changes = ["clone.0.template_uuid", "disk.0"]
  }
}
