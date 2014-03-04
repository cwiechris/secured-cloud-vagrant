require "log4r"

require_relative "power_vm"

module VagrantPlugins
	module SecuredCloud
		module Action
		
			# This can be used with "Call" built-in to check if the machine
			# is created and branch in the middleware.
			class PowerOff < PowerVm
					  
				def initialize(app, env)
					env[:ui].info(I18n.t("secured_cloud_vagrant.info.powering_off"))
					super(app, env, "off")
				end
				
			end
			
		end
	end
end