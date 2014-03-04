require "log4r"

module VagrantPlugins
	module SecuredCloud
		module Action
		
			# This can be used with "Call" built-in to check if the machine
			# is created and branch in the middleware.
			class WarnNetworks
		  
				def initialize(app, env)
					@app = app
					@machine = env[:machine]
					@logger = Log4r::Logger.new('vagrant::secured_cloud::action::warn_networks')
				end

				def call(env)
				
					@logger.debug("Checking Network Configurations included in Vagrantfile ...")

					if !@machine.config.vm.networks.nil? && @machine.config.vm.networks.length > 1
						env[:ui].warn(I18n.t('secured_cloud_vagrant.warnings.network_support'))
					end
					
					@app.call(env)
				end
				
			end
			
		end
	end
end