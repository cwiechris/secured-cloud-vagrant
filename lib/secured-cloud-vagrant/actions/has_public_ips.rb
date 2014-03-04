require "log4r"
require "secured_cloud_api_client"

module VagrantPlugins
	module SecuredCloud
		module Action
		
			# This can be used with "Call" built-in to check if the machine
			# is created and branch in the middleware.
			class HasPublicIps
			
		  
				def initialize(app, env)
					@app = app
					@machine = env[:machine]
					@logger = Log4r::Logger.new('vagrant::secured_cloud::action::has_public_ips')
				end

				def call(env)
				
					@logger.debug("Checking whether VM has public IPs ...")
					
					vm_resource_url = @machine.id
					
					if !vm_resource_url.nil? && !vm_resource_url.empty?
					
						begin
						
						# Create a Secured Cloud Connection instance to connect to the SecuredCloud API
            authInfo = @machine.provider_config.auth
            sc_connection = SecuredCloudConnection.new(authInfo.url, authInfo.applicationKey, authInfo.sharedSecret)
          
							# Get the public IPs of the VM
							publicIps = SecuredCloudRestClient.getVMPublicIPs(sc_connection, vm_resource_url)
							env[:has_public_ips] = (!publicIps.nil? && !publicIps.empty?)
							@logger.debug("Has public IPs: #{env[:has_public_ips]}")
						
						rescue Errno::ETIMEDOUT
							env[:ui].error(I18n.t('secured_cloud_vagrant.errors.request_timed_out', :request => "get the public IPs for VM #{env[:vm_name]}"))
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