require "log4r"
require "secured_cloud_api_client"

module VagrantPlugins
  module SecuredCloud
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is created and branch in the middleware.
      class ReadSshInfo
        
        
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::secured_cloud::action::read_ssh_info')
        end

        def call(env)

          @logger.debug("Reading SSH info for VM #{env[:vm_name]} ...")
          env[:vm_conn_info] = read_ssh_info(env)

          @app.call(env)
        end

        def read_ssh_info(env)

          # If the VM ID is not in the environment return null
          if @machine.id.nil? || @machine.id.empty?
            @logger.error("VM has not yet been created")
            return nil
          end

          # Initialize the public IP, port and username to those defined in the Vagrantfile
          publicIp = @machine.config.ssh.host
          port = @machine.config.ssh.port
          username = @machine.config.ssh.username

          # If they are all defined return those values
          if(!publicIp.nil? && !port.nil? && !username.nil?)
            return { :host => publicIp, :port => port, :username => username, :private_key_path => nil }
          end

          begin

            # Create a Secured Cloud Connection instance to connect tot he SecuredCloud API
            authInfo = @machine.provider_config.auth
            @sc_connection = SecuredCloudConnection.new(authInfo.url, authInfo.applicationKey, authInfo.sharedSecret)
  
            # Get the VM details
            virtualMachine = SecuredCloudRestClient.getVMDetails(@sc_connection, @machine.id)

            # If the VM is not found return null
            if virtualMachine.nil?
              @logger.error("VM '#{@machine.id}' not found")
              return nil
            end

            # Get a public IP assigned to the VM if it is not nil
            if publicIp.nil?

              publicIp = get_public_ip(virtualMachine)

              # If no public IP has been found yet return nil and show an error message
              if publicIp.nil?
                @logger.error("Cannot connect to a private VM")
                env[:ui].warn(I18n.t('secured_cloud_vagrant.warnings.no_public_ips', :vm_name => virtualMachine.get_name))
                return nil
              end

            end

            # Get the username to connect to the VM
            if username.nil?

              username = get_username(virtualMachine)

              if(username.nil?)
                @logger.warn("No username could be determined to SSH to the VM.")
              end
            end

            # If the port is not defined set it to 22
            port = 22 if port.nil?

            return { :host => publicIp, :port => port, :username => username, :private_key_path => nil }

          rescue Errno::ETIMEDOUT
            env[:ui].error(I18n.t('secured_cloud_vagrant.errors.request_timed_out', :request => "get the SSH information for VM '#{virtualMachine.get_name}'"))
          rescue Exception => e
            env[:ui].error(I18n.t("secured_cloud_vagrant.errors.generic_error", :error_message => e.message))
          end

        end

        # Returns a public IP which is assigned to the VM
        def get_public_ip(virtualMachine)

          publicIp = nil

          # Process the IP mappings of the VM
          if !virtualMachine.get_ip_mappings.nil?
            virtualMachine.get_ip_mappings.each do |ipMapping|
              
              if !ipMapping.get_public_ips.nil?
                publicIp = ipMapping.get_public_ips[0]
                @logger.debug("Public IP to SSH to VM: #{publicIp}")
                break
              end
              
            end
          end

          return publicIp
          
        end
        

        # Returns the username to SSH to the VM
        def get_username(virtualMachine)

          username = nil

          # Get username of VM
          osTemplateUrl = virtualMachine.get_os_template_resource_url

          if !osTemplateUrl.nil?

            osTemplate = SecuredCloudRestClient.getOsTemplateDetails(@sc_connection, osTemplateUrl)

            if osTemplate.nil?
              @logger.error("OsTemplate '#{osTemplateUrl}' not found")
              return nil
            end

            username = osTemplate.get_administrator_username
            @logger.debug("Username to connect to VM: #{username}")

          end

          return username
        end

      end

    end
  end
end