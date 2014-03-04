require "vagrant/action/builder"
require "log4r"
require	"pathname"

module VagrantPlugins
  module SecuredCloud
    module Action

      # Include the built-in modules so we can use them as top-level things
      include Vagrant::Action::Builtin

      # Define the logger
      @logger = Log4r::Logger::new('vagrant::secured_cloud::action');
      
      
      # This action is called to bring the box up from nothing
      def self.up

        @logger.debug("Calling 'UP' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

          builder.use ConfigValidate

          builder.use Call, CheckState do |env, b|

            case env[:machine_state]
            when :active
              env[:ui].info I18n.t('secured_cloud_vagrant.info.already_active')
            when :stopped
              b.use PowerOn
              b.use provision
            when :not_created
              b.use Create
              b.use AssignPublicIps
              b.use provision
            end

          end

          builder.use WarnNetworks

        end

      end

      # This action is called to provision a remote VM
      def self.provision

        @logger.debug("Calling 'PROVISION' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

          builder.use WarnProvision

        end

      end
      

      # This action is called to delete the VM
      def self.destroy

        @logger.debug("Calling 'DESTROY' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

          # Validate the configurations
          builder.use ConfigValidate

          builder.use Call, CheckState do |env, b|

            case env[:machine_state]
            when :not_created
              env[:ui].info I18n.t('secured_cloud_vagrant.info.not_created')
            else
              b.use Call, DestroyConfirm do |env2, b2|
  
                if(env2[:result])
    
                  # Power OFF the VM if it's ON
                  if(env[:machine_state] == :active)
                    b2.use PowerOff
                    b2.use WaitForState
                  end
      
                  b2.use Call, HasPublicIps do |env3, b3|
      
                    if(env3[:has_public_ips])
                      b3.use ReleaseIpsConfirm
                    end
        
                    b3.use Delete
                  end
                end
              end
            end
          end
        end
      end

      # This action is called to halt the VM
      def self.halt

        @logger.debug("Calling 'HALT' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

          # Validate the configurations
          builder.use ConfigValidate

          builder.use Call, CheckState do |env, b|

            case env[:machine_state]
            when :active
              b.use PowerOff
            when :stopped
              env[:ui].info I18n.t('secured_cloud_vagrant.info.already_off')
            when :not_created
              env[:ui].info I18n.t('secured_cloud_vagrant.info.not_created')
            end
          end
        end

      end

      # This action is called to halt the VM
      def self.reload

        @logger.debug("Calling 'RELOAD' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

        # Validate the configurations
          builder.use ConfigValidate

          builder.use Call, CheckState do |env, b|

            case env[:machine_state]
            when :active
              b.use Reboot
            when :stopped
              b.use PowerOn
            when :not_created
              env[:ui].info I18n.t('secured_cloud_vagrant.states.not_created.long', :vm_name => env[:machine].provider_config.vm.name)
            end
          end
        end

      end

      # This action is called to connect to the VM through SSH
      def self.ssh

        @logger.debug("Calling 'SSH' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

        # Validate the configurations
          builder.use ConfigValidate

          builder.use Call, CheckState do |env, b|

            case env[:machine_state]
            when :active
              b.use SSHExec
            when :not_created, :stopped
              vm_name = (env[:vm_name].nil? || env[:vm_name].empty?) ? env[:machine].provider_config.vm.name : env[:vm_name]
              env[:ui].info I18n.t("secured_cloud_vagrant.states.#{env[:machine_state]}.long", :vm_name => vm_name)
            end
          end
        end

      end

      # This action is called to connect to run a single SSH command
      def self.ssh_run

        @logger.debug("Calling 'SSH_RUN' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

        # Validate the configurations
          builder.use ConfigValidate

          builder.use Call, CheckState do |env, b|

            case env[:machine_state]
            when :active
              b.use SSHRun
            when :not_created, :stopped
              vm_name = (env[:vm_name].nil? || env[:vm_name].empty?) ? env[:machine].provider_config.vm.name : env[:vm_name]
              env[:ui].info I18n.t("secured_cloud_vagrant.states.#{env[:machine_state]}.long", :vm_name => vm_name)
            end

          end

        end

      end

      # This action is called to get the SSH information to connect to the VM
      def self.read_ssh_info

        @logger.debug("Calling 'READ_SSH_INFO' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

        # Validate the configurations
          builder.use ConfigValidate

          builder.use Call, CheckState do |env, b|

            case env[:machine_state]
            when :not_created
              env[:ui].info I18n.t('secured_cloud_vagrant.states.not_created.long',
              :vm_name => env[:machine].provider_config.vm.name)
            when :active, :stopped
              b.use ReadSshInfo
            end

          end

        end

      end


      # This action is called to get the state of the VM
      def self.read_machine_state

        @logger.debug("Calling 'READ_MACHINE_STATE' action ... ")

        return Vagrant::Action::Builder.new.tap do |builder|

          builder.use ConfigValidate
          builder.use CheckState
        end

      end

      # Autoload anything we might need in the action
      action_root = Pathname.new(File.expand_path("../actions", __FILE__))
      autoload :CheckState, action_root.join("check_state")
      autoload :Create, action_root.join("create")
      autoload :Delete, action_root.join("delete")
      autoload :PowerOff, action_root.join("power_off")
      autoload :PowerOn, action_root.join("power_on")
      autoload :Reboot, action_root.join("reboot")
      autoload :ReleaseIpsConfirm, action_root.join("release_ips_confirm")
      autoload :HasPublicIps, action_root.join("has_public_ips")
      autoload :ReadSshInfo, action_root.join("read_ssh_info")
      autoload :WarnNetworks, action_root.join("warn_networks")
      autoload :WarnProvision, action_root.join("warn_provision")
      autoload :WaitForState, action_root.join("wait_for_state")
      autoload :AssignPublicIps, action_root.join("assign_public_ips")
    end
  end
end
