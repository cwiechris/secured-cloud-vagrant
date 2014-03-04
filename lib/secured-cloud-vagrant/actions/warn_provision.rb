require "log4r"

module VagrantPlugins
	module SecuredCloud
		module Action
		
			# This can be used with "Call" built-in to check if the machine
			# is created and branch in the middleware.
			class WarnProvision
		  
				def initialize(app, env)
					@app = app
					@machine = env[:machine]
					@logger = Log4r::Logger.new('vagrant::secured_cloud::action::warn_provision')
				end

				def call(env)
				
					@logger.debug("Checking Provision Configurations included in Vagrantfile ...")
					
					if !@machine.config.vm.provisions.nil?
						env[:ui].warn(I18n.t('secured_cloud_vagrant.warnings.provision_support'))
					end
					
					@app.call(env)
				end
				
			end
			
		end
	end
end