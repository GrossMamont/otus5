# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
        :box_name => "rockylinux/8",
        :ip_addr => '192.168.56.101',
	:disks => {
		:sata1 => {
			:dfile => './sata1.vdi',
			:size => 2500,
			:port => 1
		},
		:sata2 => {
                        :dfile => './sata2.vdi',
                        :size => 2500, # Megabytes
			:port => 2
		},
                :sata3 => {
                        :dfile => './sata3.vdi',
                        :size => 2500,
                        :port => 3
                },
                :sata4 => {
                        :dfile => './sata4.vdi',
                        :size => 2500, # Megabytes
                        :port => 4
                }

	}

		
  },
}

Vagrant.configure("2") do |config|
        

  MACHINES.each do |boxname, boxconfig|
        

      config.vm.define boxname do |box|
          
          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s
          #box.vbguest.installer_hooks[:before_install] = ["yum install -y epel-release", "sleep 1"]
          #box.vbguest.installer_options = { allow_kernel_upgrade: false , enablerepo: true }

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            	  vb.customize ["modifyvm", :id, "--memory", "4096"]
                  needsController = false
		  boxconfig[:disks].each do |dname, dconf|
			  unless File.exist?(dconf[:dfile])
				vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                needsController =  true
                          end

		  end
                  if needsController == true
                     vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                     boxconfig[:disks].each do |dname, dconf|
                         vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                     end
                  end
          end
          box.vm.provision "shell", path: "./step1.sh"
          box.vm.provision "shell", reboot: true
          box.vm.provision "shell", path: "./step2.sh"
 	              
      end
  end
end

