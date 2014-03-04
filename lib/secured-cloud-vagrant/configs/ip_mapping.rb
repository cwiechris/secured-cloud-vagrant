require "vagrant"

module VagrantPlugins
  module SecuredCloud
    module Configuration
      class IpMapping < Vagrant.plugin(2, :config)

        attr_accessor :privateIp
        attr_accessor :newPublicIpCount
        attr_accessor :publicIpsFromReserved

        def initialize
    
          @privateIp = UNSET_VALUE
          @newPublicIpCount = UNSET_VALUE
          @publicIpsFromReserved = UNSET_VALUE
        
        end

        def validate(machine)

          errors = _detected_errors

          if !@privateIp.nil? && !@privateIp.is_a?(String)
            errors << "A valid private IP must be specified "
          end

          if !@newPublicIpCount.nil? && !@newPublicIpCount.is_a?(Integer)
            errors << "A valid public IP count must be specified "
          end
          
          if !@publicIpsFromReserved.nil? && (!@publicIpsFromReserved.is_a?(String) || !@publicIpsFromReserved.respond_to?(:each))
            errors << "A valid array of public IPs from reserve pool must be specified "
          end 

          { "Secured Cloud Provider" => errors}
          
        end
        
        
        def merge(other)
          
          super.tap do |result|
            
            if(@privateIp == other.privateIp)
              
              result.privateIp = @privateIp
              result.newPublicIpCount = (other.newPublicIpCount == UNSET_VALUE) ? @newPublicIpCount : other.newPublicIpCount
              result.publicIpsFromReserved = (other.publicIpsFromReserved == UNSET_VALUE) ? @publicIpsFromReserved : other.publicIpsFromReserved
              
            end
            
          end
          
        end
        

        def finalize!

            @privateIp = nil if (@privateIp == UNSET_VALUE)
            @newPublicIpCount = 0 if (@newPublicIpCount == UNSET_VALUE || @newPublicIpCount.nil?)
            @publicIpsFromReserved = nil if (@publicIpsFromReserved == UNSET_VALUE)
            @publicIpsFromReserved = [@publicIpsFromReserved] if @publicIpsFromReserved.is_a?(String)

        end
        
      end

    end
  end
end