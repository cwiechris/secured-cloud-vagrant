require 'log4r'
require 'secured_cloud_api_client'

module VagrantPlugins
	module SecuredCloud
		module Action
		
			class Create
								
				def initialize(app, env)
				
					@app = app
					@machine = env[:machine]
					@logger = Log4r::Logger.new('vagrant::secured_cloud::action::create')
					
				end
				
				
				def call(env)
				
					@logger.debug("Creating VM with name #{@machine.provider_config.vm.name}")
					env[:ui].info(I18n.t("secured_cloud_vagrant.info.creating"))
					
					# Create a Secured Cloud Connection instance to connect tot he SecuredCloud API
					authInfo = @machine.provider_config.auth
          sc_connection = SecuredCloudConnection.new(authInfo.url, authInfo.applicationKey, authInfo.sharedSecret)

					# Extract the parameters to pass to the createVM method
					vmName = @machine.provider_config.vm.name
					vmDescription = @machine.provider_config.vm.description
					vmStorageGB = @machine.provider_config.vm.storageGB
					vmMemoryMB = @machine.provider_config.vm.memoryMB
					vmVcpus = @machine.provider_config.vm.vcpus
					vmPowerStatus = "POWERED_ON"
					vmOsPassword = @machine.provider_config.vm.newOsPassword
					
					orgResource = @machine.provider_config.vm.orgResourceUrl
					nodeResource = @machine.provider_config.vm.nodeResourceUrl
					osTemplateResource = @machine.provider_config.vm.osTemplateUrl
					imageResource = @machine.provider_config.vm.imageResourceUrl
										
					begin
					
						# Call Rest Client to create a VM
						response = SecuredCloudRestClient::createVM(sc_connection, orgResource, nodeResource, vmName, vmDescription, vmStorageGB, vmMemoryMB, vmVcpus, vmPowerStatus, imageResource, osTemplateResource, vmOsPassword)
						
						#Monitor the transaction.
						if (response[0] == "202")

							#Task successful.
							taskResource = response[1]
							taskStatus = SecuredCloudRestClient::getTaskStatus(sc_connection, taskResource)
							
							@logger.info("Task Status:\n#{taskStatus.get_details()}")
							  
							while ((taskStatus.instance_variable_get(:@requestStateEnum) == nil) || (taskStatus.instance_variable_get(:@requestStateEnum) == "OPEN")) do
								sleep(20)
								taskStatus = SecuredCloudRestClient.getTaskStatus(sc_connection, taskResource)
                env[:ui].info(I18n.t("secured_cloud_vagrant.info.task_status", :percentage => taskStatus.get_percentage_completed, 
                  :task_desc => taskStatus.get_latest_task_description))
								@logger.info("Task Status:\n#{taskStatus.get_details()}")
							end
							 
							if(taskStatus.get_result.nil?) 
  							
  							#Task unsuccessful.
                @logger.debug("VM Creation failed with the following error:\n#{taskStatus.get_error_code}: #{taskStatus.get_error_message}")
              
                error_code = (taskStatus.get_error_code.nil?) ? "" : "#{taskStatus.get_error_code} "
                error_message = (taskStatus.get_error_message.nil?) ? I18n.t('secured_cloud_vagrant.errors.internal_server_error') : 
                  error_code + taskStatus.get_error_message
                    
                env[:ui].error(I18n.t("secured_cloud_vagrant.errors.creating_vm", :vm_name => @machine.provider_config.vm.name,
                   :error_message => error_message))
  							
  						else
  						  
  						  # Put the resource URL of the newly created VM in the environment
                env[:machine].id = taskStatus.get_result 
                env[:vm_name] = vmName
                
                @logger.debug("VM #{@machine.provider_config.vm.name} has been created with resource URL: #{env[:machine].id}")
                env[:ui].info(I18n.t("secured_cloud_vagrant.info.success.create_vm", :vm_name => @machine.provider_config.vm.name, 
                  :resource_url => env[:machine].id))
                
  						end
							
							 
						else
							
							#Task unsuccessful.
              @logger.debug("VM Creation failed with the following error:\n#{response}")
              
							error_message = (response[2].nil?) ? I18n.t('secured_cloud_vagrant.errors.internal_server_error') : response[2]
							env[:ui].error(I18n.t("secured_cloud_vagrant.errors.creating_vm", :vm_name => @machine.provider_config.vm.name, 
								:error_message => error_message))
						end
						
					rescue Errno::ETIMEDOUT
						env[:ui].error(I18n.t("secured_cloud_vagrant.errors.request_timed_out", :request => "create VM '#{vmName}'"))
          rescue Exception => e
            env[:ui].error(I18n.t("secured_cloud_vagrant.errors.generic_error", :error_message => e.message))
					end
				
					@app.call(env)
				end
				
			end
			
		end
	end
end