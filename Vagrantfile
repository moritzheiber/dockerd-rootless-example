Vagrant.configure('2') do |config|
    config.vm.box = "ubuntu/impish64"
    config.vm.provision 'shell',
                      privileged: false,
                      inline: 'cd /vagrant && ./install-rootless.sh'
end
