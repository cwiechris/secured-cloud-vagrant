require "log4r"
require "secured_cloud_api_client"

module VagrantPlugins
  module SecuredCloud
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is created and branch in the middleware.
      class Delete
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::secured_cloud::action::delete')
        end

        def call(env)

          @logger.debug("Deleting VM ...")

          vm_resource_url = @machine.id

          if !vm_resource_url.nil? & !vm_resource_url.empty?

            env[:ui].info(I18n.t("secured_cloud_vagrant.info.destroying"))

            # Create a Secured Cloud Connection instance to connect tot he SecuredCloud API
            authInfo = @machine.provider_config.auth
            sc_connection = SecuredCloudConnection.new(authInfo.url, authInfo.applicationKey, authInfo.sharedSecret)

            releasePublicIps = (env[:result].nil?) ? true : env[:result]

            @logger.debug("Release public IPs: #{releasePublicIps}")

            begin

              # Send request to delete VM
              response = SecuredCloudRestClient.deleteVM(sc_connection, vm_resource_url, releasePublicIps)

              # Monitor the transaction.
              if (response[0] == "202")

                #Task successful.
                taskResource = response[1]
                taskStatus = SecuredCloudRestClient::getTaskStatus(sc_connection, taskResource)

                @logger.info("Task Status:\n#{taskStatus.get_details()}")

                while ((taskStatus.instance_variable_get(:@requestStateEnum) == nil) || (taskStatus.instance_variable_get(:@requestStateEnum) == "OPEN")) do
                  sleep(20)
                  taskStatus = SecuredCloudRestClient.getTaskStatus(sc_connection, taskResource)
                  env[:ui].info(I18n.t('secured_cloud_vagrant.info.task_status', :percentage => taskStatus.get_percentage_completed, 
                    :task_desc => taskStatus.get_latest_task_description))
                  @logger.info("Task Status:\n#{taskStatus.get_details()}")
                end

                if(taskStatus.get_result.nil?)

                  #Task unsuccessful.
                  @logger.debug("VM Deletion failed with the following error:\n#{taskStatus.get_error_code}: #{taskStatus.get_error_message}")

                  error_code = (taskStatus.get_error_code.nil?) ? "" : "#{taskStatus.get_error_code} "
                  error_message = (taskStatus.get_error_message.nil?) ? I18n.t('secured_cloud_vagrant.errors.internal_server_error') : 
                    error_code + taskStatus.get_error_message  
                    
                  env[:ui].error(I18n.t("secured_cloud_vagrant.errors.deleting_vm", :vm_name => env[:vm_name], :error_message => error_message))

                else

                  # Set the resource URL of the delete VM to null in the environment
                  @logger.debug("VM '#{env[:machine].id}' has been deleted")
                  env[:ui].info(I18n.t("secured_cloud_vagrant.info.success.delete_vm", :vm_name => env[:vm_name]))

                  env[:machine].id = nil
                  env[:vm_name] = nil

                end

              else

                #Task unsuccessful.
                @logger.debug("VM Deletion failed with the following error:\n#{response}")

                error_message = (response[2].nil?) ? I18n.t('secured_cloud_vagrant.errors.internal_server_error') : response[2]
                env[:ui].error(I18n.t("secured_cloud_vagrant.errors.deleting_vm", :vm_name => env[:vm_name], :error_message => error_message))
                
              end

            rescue Errno::ETIMEDOUT
              env[:ui].error(I18n.t("secured_cloud_vagrant.errors.request_timed_out", :request => "delete VM '#{@machine.provider_config.vm.name}'"))
            rescue Exception => e
              env[:ui].error(I18n.t("secured_cloud_vagrant.errors.generic_error", :error_message => e.message))
            end

          else
            @logger.debug("No VM found to be deleted")
          end

          @app.call(env)
        end

      end

    end
  end
end