resource "vsphere_virtual_machine" "vyos-apartment" {
  name             = "vyos-apartment"
  tags             = [vsphere_tag.vyos.id]
  resource_pool_id = vsphere_compute_cluster.apartment_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.esxi-apartment.id
  num_cpus         = 4
  memory           = 2048
  guest_id         = data.vsphere_virtual_machine.vyos-1_2.guest_id
  network_interface {
    network_id   = vsphere_distributed_port_group.apartment_lan.id
    adapter_type = "vmxnet3"
    bandwidth_share_level = "high"
  }
  network_interface {
    network_id     = vsphere_distributed_port_group.apartment_dedicated_wan.id
    adapter_type   = "vmxnet3"
    use_static_mac = true
    mac_address    = "00:50:56:a7:5e:6e"
    bandwidth_share_level = "high"
  }
  disk {
    label = "disk0"
    size  = 4
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.vyos-1_2.id
  }

  # Configure the network
  provisioner "local-exec" {
    working_dir = "../"
    command     = "ansible-playbook ansible/vyos/network.yml -u david -i '${vsphere_virtual_machine.vyos.default_ip_address},' -e 'ansible_network_os=vyos' -e 'host_key_checking=False'"
  }
  # Prevent terraform from recreating VMs when we update the template
  lifecycle {
    ignore_changes = [clone.0.template_uuid, disk.0]
  }
}

