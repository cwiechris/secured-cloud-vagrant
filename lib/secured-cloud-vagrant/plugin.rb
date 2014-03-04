begin
	require "vagrant"
rescue LoadError
	raise "This plugin must run within Vagrant."
end

module VagrantPlugins
	module SecuredCloud
	
		class SecuredCloudPlugin < Vagrant.plugin('2')
		
			name 'Secured Cloud Vagrant Plugin'
			
			description <<-DESC
			This plugin installs a provider that allows Vagrant to manage virtual machine in Secured Cloud
			DESC
			
			provider('secured_cloud') do
			
				# Setup logging
				setup_logging
			
				require_relative "provider"
				SecuredCloudProvider
			end
			
			config(:secured_cloud, :provider) do
				require_relative "configs/config"
				Configuration::Config
			end

			
			command('ssh-config') do
				require_relative "commands/ssh_config"
				Command::SshConfig
			end
			
			
			command('list') do
			  require_relative "commands/list"
			  Command::List
			end
			
			
			def self.setup_logging
			
				require "log4r"
				
				level = nil
				
				begin
					level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
				rescue NameError
					# This means that the logging constant wasn't found,
					# which is fine. We just keep `level` as `FATAL`. But
					# we tell the user.
					level = Log4r.const_get('FATAL')
				end

				# Some constants, such as "true" resolve to booleans, so the
				# above error checking doesn't catch it. This will check to make
				# sure that the log level is an integer, as Log4r requires.
				level = nil if !level.is_a?(Integer)
				
				# Set the logging level on all "vagrant" namespaced
				# logs as long as we have a valid level.
				if level
					logger = Log4r::Logger.new('vagrant::secured_cloud')
					logger.outputters = Log4r::Outputter.stdout
					logger.level = level
					logger = nil
				end
						
			end
		end
	end
end
