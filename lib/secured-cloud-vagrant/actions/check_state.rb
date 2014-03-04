require "log4r"
require "secured_cloud_api_client"

module VagrantPlugins
	module SecuredCloud
		module Action
		
			# This can be used with "Call" built-in to check if the machine
			# is created and branch in the middleware.
			class CheckState
			
				def initialize(app, env)
					@app = app
					@machine = env[:machine]
					@logger = Log4r::Logger.new('vagrant::secured_cloud::action::check_state')
				end

				def call(env)
				
					@logger.debug("Checking VM state ...")
					
					vm_resource_url = @machine.id
					
					if vm_resource_url.nil? || vm_resource_url.empty?
						env[:machine_state] = :not_created
					else
					
						begin
						  
						  # Create a Secured Cloud Connection instance to connect tot he SecuredCloud API
              authInfo = @machine.provider_config.auth
              sc_connection = SecuredCloudConnection.new(authInfo.url, authInfo.applicationKey, authInfo.sharedSecret)
						
							# Get the VM details
							virtualMachine = SecuredCloudRestClient.getVMDetails(sc_connection, vm_resource_url)
								
							# Set the VM name
							env[:vm_name] = virtualMachine.get_name
							@logger.debug("VM Name: '#{env[:vm_name]}'")
								
							# Get the VM power status
							if (virtualMachine.get_power_status == "POWERED_OFF")
								env[:machine_state] = :stopped
							elsif (virtualMachine.get_power_status == "POWERED_ON")
								env[:machine_state] = :active
							end
							
							@logger.debug("State for VM #{vm_resource_url} is #{env[:machine_state]}")
							
						rescue Errno::ETIMEDOUT
							env[:ui].error(I18n.t("secured_cloud_vagrant.errors.request_timed_out", :request => "get the VM details"))
						rescue Exception => e
						  env[:ui].error(I18n.t("secured_cloud_vagrant.errors.generic_error", :error_message => e.message))
						end
					end				
					
					@app.call(env)
				end
				
			end
			
		end
	end
end