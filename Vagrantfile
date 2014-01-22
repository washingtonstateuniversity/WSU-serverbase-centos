# WSU Server Base Vagrant Configuration
#
# Matches the WSU Server environment production setup as closely as possible.
# This will auto edit some of the local provisioning file but not the production.
# All production states/grains/pillars are to be managed by hand.
#
# We recommend Vagrant 1.3.5 and Virtualbox 4.3.
#
# -*- mode: ruby -*-
# vi: set ft=ruby :

#######################
# CONFIG Values
#####################

ip="10.10.30.30"        # (str) default:10.10.30.30             - ip of the VirturalBox
hostname="WSUBASE"      # (str) default:WSUBASE                 - name of the host
memory=512              # (int) default:512                     - How much memory would you like to share from your host
cores=2                 # (int) default:1                       - How many processor from the host do you want to share
host_64bit=true         # (bool) default:false                  - If you are on windows and are sharing more then 2 cores set to true
install_type='testing'  # (testing) default:testing             - Type of install
minion='vagrant'        # (vagrant/production) default:vagrant  - Which minion to run
verbose_output=true     # (bool) default:true                   - How much do you want to see in the console


#######################
# Setup
######################

# There shouldn't be anything to edit below this point config wise
####################################################################


    ################################################################ 
    # Setup value defaults
    ################################################################ 
    
        #base dir
        ################################################################ 
        vagrant_dir = File.expand_path(File.dirname(__FILE__))
        
        # the sub projects :: writes out the salt "config data" and 
        # sets up for vagrant.  The production is done by hand on purpose
        ###############################################################
    
        filename = vagrant_dir+"/provision/salt/minions/#{minion}.conf"
        text = File.read(filename)
        
        PILLARFILE=   "#PILLAR_ROOT-\n"
        PILLARFILE << "pillar_roots:\n"
        PILLARFILE << "  base:\n"
        PILLARFILE << "    - /srv/salt/base/pillar\n"

        ROOTFILE=   "#FILE_ROOT-\n"
        ROOTFILE << "file_roots:\n"
        ROOTFILE << "  base:\n"
        ROOTFILE << "    - /srv/salt/base\n"
        
        SALT_ENV=   "#ENV_START-\n"
        SALT_ENV << "  env:\n"
        SALT_ENV << "    - base\n"
        SALT_ENV << "    - vagrant\n"
    
        projects = []
        paths = []
        Dir.glob(vagrant_dir + "/www/*/provision/salt/pillar/project.sls").each do |path|
          paths << path
        end
        paths.each do |path|
            lines = IO.read(path).split( "\n" )
            lines.each do |line|
                if line.include? "target"
                    target=line.split(":").last
                    project=target.strip! || target
                    projects <<  project
                    
                    SALT_ENV << "    - #{project}\n"
        
                    PILLARFILE << "  #{project}:\n"
                    PILLARFILE << "    - /srv/salt/#{project}/pillar\n"
                    
                    ROOTFILE << "  #{project}:\n"
                    ROOTFILE << "    - /srv/salt/#{project}\n"
                end
            end
        end
    
        SALT_ENV << "#ENV_END-"
        PILLARFILE << "#END_OF_PILLAR_ROOT-"
        ROOTFILE << "#END_OF_FILE_ROOT-"
 
        edited = text.gsub(/\#FILE_ROOT-.*\#END_OF_FILE_ROOT-/im, ROOTFILE)
        edited = edited.gsub(/\#PILLAR_ROOT-.*\#END_OF_PILLAR_ROOT-/im, PILLARFILE)
        edited = edited.gsub(/\#ENV_START-.*\#ENV_END-/im, SALT_ENV)
        File.open(filename, "w") { |file| file << edited }
    
        # set defaults ?? maybe go away ??
        ################################################################
        minion = minion.to_s.empty? ? 'vagrant' : minion
        ip = ip.to_s.empty? ? '10.10.30.30' : ip
        memory = memory.to_s.empty? ? 512 : memory
        cores = cores.to_s.empty? ? 1 : cores
        hostname = hostname.to_s.empty? ? "WSUBASE" : hostname
        install_type = install_type.to_s.empty? ? "testing" : install_type
        host_64bit = host_64bit.to_s.empty? ? false : host_64bit


        # we need these and have the ablilty to install this for them, do so
        #output = `vagrant plugin list`
        #if !output.include? "vagrant-hostsupdater"
        #    puts "hostsupdater not loaded but needed\ninstalling vagrant-hostsupdater plugin"
        #    puts `vagrant plugin install vagrant-hostsupdater`
        #end
        #if !output.include? "vagrant-vbguest"
        #    puts "installing vagrant-vbguest plugin"
        #    puts `vagrant plugin install vagrant-vbguest`
        #end 



    ################################################################ 
    # Start Vagrant
    ################################################################   
    Vagrant.configure("2") do |config|

        # Virtualbox specific settings for the virtual machine.
        ################################################################ 
        config.vm.provider :virtualbox do |v|
            v.gui = false
            v.name = hostname
            v.memory = memory
            if cores>1
                v.customize ["modifyvm", :id, "--cpus", cores]
                if host_64bit
                    v.customize ["modifyvm", :id, "--ioapic", "on"]
                end
            end
        end
        

        # CentOS 6.4, 64 bit release
        ################################################################  
        config.vm.box     = "centos-64-x64-puppetlabs"
        config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box"
        
        # Set networking options
        ################################################################           
        if !(hostname.nil? || !hostname.empty?)
            config.vm.hostname = hostname
        end
        config.vm.network :private_network, ip: ip


        # register hosts for all apps and the server
        ################################################################
        APPHOSTS=   "#APP_HOSTS-\n"
        APPHOSTS << "127.0.0.1           demo\n"
        # Local Machine Hosts
            # Capture the paths to all `hosts` files under the repository's provision directory.
            paths = []
            hosts = []
            projects.each do |project|
                Dir.glob(vagrant_dir + "/www/#{project}/provision/salt/config/hosts").each do |path|
                  paths << path
                end
                # Parse through the `hosts` files in each of the found paths and put the hosts
                # that are found into a single array. Lines commented out with # will be skipped.
                
                paths.each do |path|
                  new_hosts = []
                  file_hosts = IO.read(path).split( "\n" )
                  file_hosts.each do |line|
                    if line[0..0] != "#"
                      new_hosts << line
                      APPHOSTS << "127.0.0.1           #{line}\n"
                    end
                  end
                  hosts.concat new_hosts
                end
            end
        if defined? VagrantPlugins::HostsUpdater
            config.hostsupdater.aliases = hosts
        end
        
        
        APPHOSTS << "#ENDOF_APP_HOSTS-"
        filename = vagrant_dir+"/provision/salt/config/hosts"
        text = File.read(filename) 
        edited = text.gsub(/\#APP_HOSTS-.*\#ENDOF_APP_HOSTS-/im, APPHOSTS)
        File.open(filename, "w") { |file| file << edited }
         
        # Set file mounts
        ################################################################           
        # Mount the local project's www/ directory as /var/www inside the virtual machine. This will
        # be mounted as the 'vagrant' user at first, then unmounted and mounted again as 'www-data'
        # during provisioning.
        config.vm.synced_folder "www", "/var/www", :mount_options => [ "uid=510,gid=510", "dmode=775", "fmode=774" ]

        # Provisioning: Salt 
        ################################################################      
        # Map the provisioning directory to the guest machine and initiate the provisioning process
        # with salt. On the first build of a virtual machine, if Salt has not yet been installed, it
        # will be bootstrapped automatically. We have provided a modified local bootstrap script to
        # avoid network connectivity issues and to specify that a newer version of Salt be installed.
        
        config.vm.synced_folder "provision/salt", "/srv/salt/base"
        
        $provision_script=""
        $provision_script<<"cp /srv/salt/base/config/yum.conf /etc/yum.conf\n"
        $provision_script<<"sh /srv/salt/base/boot/bootstrap_salt.sh\n"
        $provision_script<<"cp /srv/salt/base/minions/#{minion}.conf /etc/salt/minion.d/\n"
        $provision_script<<"salt-call --local --log-level=info --config-dir=/etc/salt state.highstate env=base\n"
        # Set up the project apps
        #########################
        projects.each do |project| 
            config.vm.synced_folder "www/#{project}/provision/salt", "/srv/salt/#{project}"
            $provision_script<<"salt-call --local --log-level=info --config-dir=/etc/salt state.highstate env=#{project}\n"
        end
        config.vm.provision "shell", inline: $provision_script
    end