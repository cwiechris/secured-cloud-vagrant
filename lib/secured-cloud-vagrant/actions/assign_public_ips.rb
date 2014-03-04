require 'log4r'
require 'secured_cloud_api_client'

module VagrantPlugins
  module SecuredCloud
    module Action
      class AssignPublicIps
        def initialize(app, env)

          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::secured_cloud::action::assign_public_ips')

        end

        def call(env)

          @logger.debug("Assigning public IPs to VM with name #{@machine.provider_config.vm.name}")

          if @machine.id.nil? || @machine.id.empty?
            @logger.debug("The VM has not been created")
            return
          end

          ipMappings = @machine.provider_config.vm.ipMappings

          if ipMappings.nil? || ipMappings.empty?
            @logger.debug("The VM has not been assigned any public IPs")
          else

            env[:ui].info(I18n.t("secured_cloud_vagrant.info.assigning_public_ips"))

            # Create a Secured Cloud Connection instance to connect tot he SecuredCloud API
            authInfo = @machine.provider_config.auth
            @sc_connection = SecuredCloudConnection.new(authInfo.url, authInfo.applicationKey, authInfo.sharedSecret)

            ipMappings.each do |ipMapping|

              # Extract the parameters to pass to the assign public IP method
              privateIp = ipMapping.privateIp
              publicIpCount = ipMapping.newPublicIpCount
              publicIpsFromReserved = ipMapping.publicIpsFromReserved

              # Process the public IPs from global pool
              publicIpCount.times do |n|
                @logger.debug("Assigning public IP from global pool to private IP #{privateIp}")
                assign_public_ip(privateIp, nil, env)
              end

              # Process the public IPs from reserve pool
              if !publicIpsFromReserved.nil? && !publicIpsFromReserved.empty?

                publicIpsFromReserved.each do |reservedIp|
                  @logger.debug("Assigning public IP from reserve pool '#{reservedIp}' to private IP #{privateIp}")
                  assign_public_ip(privateIp, reservedIp, env)
                end

              end

            end

          end

          @app.call(env)

        end

        def assign_public_ip(private_ip, public_ip, env)

          begin

            # Call Rest Client to assign a public IP
            response = SecuredCloudRestClient::assignPublicIpToVM(@sc_connection, @machine.id, public_ip, private_ip)

            # Monitor the transaction.
            if (response[0] == "202")

              # Task successful.
              taskResource = response[1]
              taskStatus = SecuredCloudRestClient::getTaskStatus(@sc_connection, taskResource)

              @logger.info("Task Status:\n#{taskStatus.get_details()}")

              while ((taskStatus.instance_variable_get(:@requestStateEnum) == nil) || (taskStatus.instance_variable_get(:@requestStateEnum) == "OPEN")) do
                sleep(20)
                taskStatus = SecuredCloudRestClient.getTaskStatus(@sc_connection, taskResource)
                env[:ui].info(I18n.t('secured_cloud_vagrant.info.task_status', :percentage => taskStatus.get_percentage_completed, 
                  :task_desc => taskStatus.get_latest_task_description))
                @logger.info("Task Status:\n#{taskStatus.get_details()}")
              end

              if(taskStatus.get_result.nil?)

                #Task unsuccessful.
                @logger.debug("Public IP assignment failed with the following error:\n#{taskStatus.get_error_code}: #{taskStatus.get_error_message}")

                error_code = (taskStatus.get_error_code.nil?) ? "" : "#{taskStatus.get_error_code} "
                error_message = (taskStatus.get_error_message.nil?) ? I18n.t('secured_cloud_vagrant.errors.internal_server_error') : 
                  error_code + taskStatus.get_error_message
                  
                env[:ui].error(I18n.t("secured_cloud_vagrant.errors.assigning_public_ip", :vm_name => env[:vm_name], :error_message => error_message))

              else

                # Task successful
                if(public_ip.nil?)

                  @logger.debug("VM #{env[:vm_name]} has been assigned a public IP from the global pool")
                  env[:ui].info(I18n.t("secured_cloud_vagrant.info.success.assign_public_ip.global_pool", :vm_name => env[:vm_name]))
                  
                else
                  
                  @logger.debug("VM #{env[:vm_name]} has been assigned public IP '#{public_ip}' from the reserve pool")
                  env[:ui].info(I18n.t("secured_cloud_vagrant.info.success.assign_public_ip.reserve_pool", :vm_name => env[:vm_name],
                    :public_ip => public_ip))
                end

              end

            else

              # Task unsuccessful.
              @logger.debug("Public IP assignment failed with the following error:\n#{response}")

              error_message = (response[2].nil?) ? I18n.t('secured_cloud_vagrant.errors.internal_server_error') : response[2]
              env[:ui].error(I18n.t("secured_cloud_vagrant.errors.assigning_public_ip", :vm_name => env[:vm_name],
                :error_message => error_message))

            end

          rescue Errno::ETIMEDOUT
            env[:ui].error(I18n.t("secured_cloud_vagrant.errors.request_timed_out", :request => "assign a public IP"))
          rescue Exception => e
            env[:ui].error(I18n.t("secured_cloud_vagrant.errors.generic_error", :error_message => e.message))
          end

        end

      end
    end
  end
end