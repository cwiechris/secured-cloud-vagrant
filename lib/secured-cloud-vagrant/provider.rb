require "vagrant"

module VagrantPlugins
	module SecuredCloud
		class SecuredCloudProvider < Vagrant.plugin(2, :provider)

			def initialize(machine)
				@machine = machine
			end
			
			
			def action(name)
				
				# Attempt to get the action method from the Action class if it
				# exists, otherwise return nil to show that we don't support the
				# given action.
				return Action.send(name) if Action.respond_to?(name)
				nil
			end
			
			# This method is called if the underlying machine ID changes. Providers
			# can use this method to load in new data for the actual backing
			# machine or to realize that the machine is now gone (the ID can
			# become `nil`). No parameters are given, since the underlying machine
			# is simply the machine instance given to this object. And no
			# return value is necessary.
			def machine_id_changed
			end
			
			# This should return a hash of information that explains how to
			# SSH into the machine. If the machine is not at a point where
			# SSH is even possible, then `nil` should be returned.
			#
			# The general structure of this returned hash should be the
			# following:
			#
			#     {
			#       :host => "1.2.3.4",
			#       :port => "22",
			#       :username => "mitchellh",
			#       :private_key_path => "/path/to/my/key"
			#     }
			#
			# **Note:** Vagrant only supports private key based authentication,
			# mainly for the reason that there is no easy way to exec into an
			# `ssh` prompt with a password, whereas we can pass a private key
			# via commandline.
			#
			# @return [Hash] SSH information. For the structure of this hash
			#   read the accompanying documentation for this method.
			def ssh_info
				env = @machine.action(:read_ssh_info)
				env[:vm_conn_info]
			end
			
			# This should return the state of the machine within this provider.
			# The state must be an instance of {MachineState}. Please read the
			# documentation of that class for more information.
			def state
			
				env = @machine.action("read_machine_state")
				
				vm_name = (env[:vm_name].nil? || env[:vm_name].empty?) ? env[:machine].provider_config.vm.name : env[:vm_name]
			
				state = (env[:machine_state].nil?) ? :unknown : env[:machine_state]
				short_desc = I18n.t("secured_cloud_vagrant.states.#{state}.short") 
				long_desc = I18n.t("secured_cloud_vagrant.states.#{state}.long", :vm_name => vm_name) 
				
				Vagrant::MachineState.new(state, short_desc, long_desc)
			end
		end
	end
end