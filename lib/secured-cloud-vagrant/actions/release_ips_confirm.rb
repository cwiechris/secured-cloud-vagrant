require "vagrant/action/builtin/confirm"
require "log4r"

module VagrantPlugins
	module SecuredCloud
		module Action
	
			# This class asks the user to confirm whether the public IPs of 
			# the VM managed by vagrant are to be released or put in the reserve 
			# pool of the VDC. 
			class ReleaseIpsConfirm < Confirm
		  
				def initialize(app, env)
					
					@logger = Log4r::Logger.new('vagrant::secured_cloud::action::release_ips_confirm')
					@logger.debug("Confirming whether public IPs are to be released ...")
					
					message = I18n.t('secured_cloud_vagrant.commands.release_ips_confirmation')
					super(app, env, message)
				end
			end
	  
		end
	end
end
