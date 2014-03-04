require "log4r"
require "secured_cloud_api_client"

module VagrantPlugins
	module SecuredCloud
		module Action
		
			# This can be used with "Call" built-in to check if the machine
			# is created and branch in the middleware.
			class WaitForState
			
				def initialize(app, env)
					@app = app
					@machine = env[:machine]
					@logger = Log4r::Logger.new('vagrant::secured_cloud::action::wait_for_state')
				end

				def call(env)
				
					@logger.debug("Waiting for VM state to be powered OFF ...")
					
					vm_resource_url = @machine.id
					
					if !vm_resource_url.nil? && !vm_resource_url.empty?
					
						begin
						  
						  # Create a Secured Cloud Connection instance to connect tot he SecuredCloud API
              authInfo = @machine.provider_config.auth
              sc_connection = SecuredCloudConnection.new(authInfo.url, authInfo.applicationKey, authInfo.sharedSecret)
						
						  # Get the VM details and check the power status
						 while (SecuredCloudRestClient.getVMDetails(sc_connection, vm_resource_url).get_power_status == "POWERED_ON") do
							  
							  # Sleep for 2 seconds
                sleep 2
							  
							end
							
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