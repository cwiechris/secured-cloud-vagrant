require "vagrant"

require_relative "virtual_machine"
require_relative "authentication_info"

module VagrantPlugins
  module SecuredCloud
    module Configuration
      
      class Config < Vagrant.plugin(2, :config)
    
        attr_accessor :vm
        attr_accessor :auth
        
        
        def initialize
  
          @vm = VirtualMachine.new
          @auth = AuthenticationInfo.new
  
        end
  
        def validate(machine)
  
          errors = _detected_errors
  
          # Validate the VM only if we don't specifically specify otherwise
          if @vm.nil?
             errors << "The VM properties must be properly defined "
          else
             @vm.validate(machine)
          end
  
          if @auth.nil?
            errors << "The authentication properties must be properly defined "
          else
            @auth.validate(machine)
          end
  
          { "Secured Cloud Provider" => errors}
  
        end
  
        def merge(other)
  
          super.tap do |result|
  
            if(other.vm == UNSET_VALUE || other.vm.nil?)
              result.vm = @vm
            elsif @vm == UNSET_VALUE || @vm.nil?
              result.vm = other.vm
            else
              result.vm = @vm.merge(other.vm)
            end
  
            if(other.auth == UNSET_VALUE || other.auth.nil?)
              result.auth = @auth
            elsif @auth == UNSET_VALUE || @auth.nil?
              result.auth = other.auth
            else
              result.auth = @auth.merge(other.auth)
            end
  
          end
        end
  
        def finalize!
  
          if (@vm == UNSET_VALUE || @vm == nil)
            @vm = VirtualMachine.new
          else
            @vm.finalize!
          end
  
          if (@auth == UNSET_VALUE || @auth == nil)
            @auth = VirtualMachine.new
          else
            @auth.finalize!
          end
  
        end
  
      end

    end
  end
end