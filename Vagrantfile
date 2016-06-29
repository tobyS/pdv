# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.hostname = "pdv.local"
    config.vm.network :private_network, ip: "33.33.33.88"

    config.vm.provider :virtualbox do |vb|
        config.vm.box = "ubuntu/trusty64"

        vb.name = "PDV VIM Tests"

        # Properly configure the vm to use the available amount of cores
        vb.customize ["modifyvm", :id, "--cpus", `#{RbConfig::CONFIG['host_os'] =~ /darwin/ ? 'sysctl -n hw.ncpu' : 'nproc'}`.chomp]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]

        vb.customize ["modifyvm", :id, "--memory", 2048]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    config.vm.provision "ansible" do |ansible|
        ansible.inventory_path = "ansible/vagrant"
        ansible.limit = "all"
        ansible.playbook = "ansible/setup.yml"
        ansible.verbose = false

        if ENV['ANSIBLE_SKIP_TAGS'] != nil
            puts "Setting ansible.skip_tags=#{ENV['ANSIBLE_SKIP_TAGS']}"
            ansible.skip_tags = "#{ENV['ANSIBLE_SKIP_TAGS']}"
        end
        if ENV['ANSIBLE_TAGS'] != nil
            puts "Setting ansible.tags=#{ENV['ANSIBLE_TAGS']}"
            ansible.tags = "#{ENV['ANSIBLE_TAGS']}"
        end
    end

    config.vm.synced_folder "./", "/home/vagrant/pdv", :nfs => (RUBY_PLATFORM =~ /linux/ or RUBY_PLATFORM =~ /darwin/)
end
