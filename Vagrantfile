Vagrant.configure("2") do |config|
  box = ENV.fetch("VAGRANT_BOX", "ubuntu/jammy64")
  config.vm.box = box
  config.ssh.insert_key = false

  nodes = {
    "ansible" => { ip: "192.168.56.10", cpus: 3, memory: 3072 },
    "lb"      => { ip: "192.168.56.20", cpus: 2, memory: 2048 },
    "cp1"     => { ip: "192.168.56.21", cpus: 4, memory: 4096 },
    "cp2"     => { ip: "192.168.56.22", cpus: 2, memory: 3072 },
    "cp3"     => { ip: "192.168.56.23", cpus: 2, memory: 3072 },
    "worker1" => { ip: "192.168.56.31", cpus: 2, memory: 3072 },
    "worker2" => { ip: "192.168.56.32", cpus: 2, memory: 3072 }
  }

  nodes.each do |name, opts|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: opts[:ip]

      node.vm.provider "virtualbox" do |vb|
        vb.cpus = opts[:cpus]
        vb.memory = opts[:memory]
      end

      if name == "ansible"
        node.vm.provision "shell", path: "bootstrap/ansible-controller.sh", privileged: true
      end
    end
  end
end
