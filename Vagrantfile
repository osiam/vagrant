require 'yaml'

configuration = YAML.load(File.open(File.join(File.dirname(__FILE__), 'config.yaml'), File::RDONLY).read)

Vagrant.configure(2) do |config|
  source_path = configuration['sourcePath']
  memory = configuration['memory']
  web_port = configuration['webPort']
  db_port = configuration['dbPort']

  config.vm.box = 'debian/jessie64'
  config.vm.hostname = 'osiam-dev'
  config.vm.synced_folder source_path, "/media/source"
  config.vm.network :forwarded_port, :guest => 8080, :host => web_port
  config.vm.network :forwarded_port, :guest => 5432, :host => db_port
  config.vm.network :forwarded_port, :guest => 8180, :host => 8180
  config.vm.network :forwarded_port, :guest => 15432, :host => 15432
  config.vm.network :forwarded_port, :guest => 13306, :host => 13306
  config.vm.network :forwarded_port, :guest => 11110, :host => 11110
  config.vm.provider :virtualbox do |vb|
    vb.memory = memory
    vb.cpus = 2
  end

  config.vm.provision :shell,
                      inline: "echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list"

  config.vm.provision :shell,
                      inline: "sudo apt-get update -qq && sudo apt-get install apt-transport-https -y"

  config.vm.provision :docker

  config.vm.provision :file, :source => 'install', :destination => '/tmp/'

  config.vm.provision :shell, :path => 'bootstrap.sh'

end
