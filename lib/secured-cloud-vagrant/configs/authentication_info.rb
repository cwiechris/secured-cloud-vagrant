require "vagrant"

module VagrantPlugins
	module SecuredCloud
		module Configuration

			class AuthenticationInfo < Vagrant.plugin(2, :config)

        attr_accessor :url
				attr_accessor :applicationKey
				attr_accessor :sharedSecret
			
				def initialize
				  @url = UNSET_VALUE
				  @applicationKey = UNSET_VALUE
				  @sharedSecret = UNSET_VALUE
				end
				
				def validate(machine)
				  
				end
				
				def merge(other)
				  
				  super.tap do |result|
				    
				    result.url = (other.url == UNSET_VALUE) ? @url : other.url
				    result.applicationKey = (other.applicationKey == UNSET_VALUE) ? @url : other.applicationKey
				    result.sharedSecret = (other.sharedSecret == UNSET_VALUE) ? @sharedSecret : other.sharedSecret
				    
				  end
				  
				end
				
				
				def finalize!
				
				  @url = nil if(@url == UNSET_VALUE)
				  @applicationKey = nil if(@applicationKey == UNSET_VALUE)
				  @sharedSecret = nil if(@sharedSecret == UNSET_VALUE)
				  
				end
				
			end
			
		end
	end
end
	