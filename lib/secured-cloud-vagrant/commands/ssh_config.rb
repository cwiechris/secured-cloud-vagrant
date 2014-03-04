require "vagrant"

module VagrantPlugins
	module SecuredCloud
	  module Command
	  
  		class SshConfig < Vagrant.plugin(2, :command)
  
  			def self.synopsis
  				"Outputs OpenSSH valid configuration to connect to the machine"
  			end
  
  			def execute
  				options = {}
  
  				opts = OptionParser.new do |o|
  					o.banner = "Usage: vagrant ssh-config [vm-name] [--host name]"
  					o.separator ""
  
  					o.on("--host COMMAND", "Name the host for the config..") do |h|
  						options[:host] = h
  					end
  				end
  
  				argv = parse_options(opts)
  				return if !argv
  
  				with_target_vms(argv, :single_target => true) do |machine|
  					env = machine.action(:read_ssh_info)
  					
  					unless env[:vm_conn_info].nil? then
  					   env[:ui].info(I18n.t('secured_cloud_vagrant.commands.vm-config', :host_name => env[:vm_conn_info][:host], 
                  :port => env[:vm_conn_info][:port], :username => env[:vm_conn_info][:username]))
            end 
  				end
  
  				# Success, exit status 0
  				0
  			end
  		end
		end
	end
end