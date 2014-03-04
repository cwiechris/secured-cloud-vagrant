require "vagrant"

require_relative "ip_mapping"

module VagrantPlugins
  module SecuredCloud
    module Configuration
      class VirtualMachine < Vagrant.plugin(2, :config)

        attr_accessor :name
        attr_accessor :description
        attr_accessor :storageGB
        attr_accessor :memoryMB
        attr_accessor :vcpus
        attr_accessor :osTemplateUrl
        attr_accessor :imageResourceUrl
        attr_accessor :newOsPassword
        attr_accessor :nodeResourceUrl
        attr_accessor :orgResourceUrl
        attr_accessor :ipMappings
        
        
        def initialize

          @name = UNSET_VALUE
          @description = UNSET_VALUE
          @storageGB = UNSET_VALUE
          @memoryMB = UNSET_VALUE
          @vcpus = UNSET_VALUE
          @osTemplateUrl = UNSET_VALUE
          @imageResourceUrl = UNSET_VALUE
          @newOsPassword = UNSET_VALUE
          @nodeResourceUrl = UNSET_VALUE
          @orgResourceUrl = UNSET_VALUE
          @ipMappings = UNSET_VALUE

        end

        def validate(machine)

          errors = _detected_errors

          if @name.nil? || @name.empty?
            errors << "The VM name must be properly defined "
          end

          if !@ipMappings.nil? && !@ipMappings.respond_to?(:each)
            errors << "A valid array of IP mappings must be specified "
          else
            @ipMappings.each do |ipMapping|
              ipMapping.validate(machine)
            end
          end

          { "Secured Cloud Provider" => errors}
          
        end
        

        def merge(other)

          super.tap do |result|

            result.name = (other.name == UNSET_VALUE) ? @name : other.name
            result.description = (other.description == UNSET_VALUE) ? @description : other.description
            result.storageGB = (other.storageGB == UNSET_VALUE) ? @storageGB : other.storageGB
            result.memoryMB = (other.memoryMB == UNSET_VALUE) ? @memoryMB : other.memoryMB
            result.vcpus = (other.vcpus == UNSET_VALUE) ? @vcpus : other.vcpus
            result.osTemplateUrl = (other.osTemplateUrl == UNSET_VALUE) ? @osTemplateUrl : other.osTemplateUrl
            result.imageResourceUrl = (other.imageResourceUrl == UNSET_VALUE) ? @imageResourceUrl : other.imageResourceUrl
            result.newOsPassword = (other.newOsPassword == UNSET_VALUE) ? @newOsPassword : other.newOsPassword
            result.nodeResourceUrl = (other.nodeResourceUrl == UNSET_VALUE) ? @nodeResourceUrl : other.nodeResourceUrl
            result.orgResourceUrl = (other.orgResourceUrl == UNSET_VALUE) ? @orgResourceUrl : other.orgResourceUrl

            if(other.ipMappings == UNSET_VALUE || other.ipMappings.nil?)
              result.ipMappings = @ipMappings
            elsif @ipMappings == UNSET_VALUE || @ipMappings.nil?
              result.ipMappings = other.ipMappings
            else
              result.ipMappings = @ipMappings.concat(other.ipMappings)
            end

          end
        end

        def finalize!

          @name = nil if (@name == UNSET_VALUE)
          @description = nil if (@description == UNSET_VALUE)
          @storageGB = nil if (@storageGB == UNSET_VALUE)
          @memoryMB = nil if (@memoryMB == UNSET_VALUE)
          @vcpus = nil if (@vcpus == UNSET_VALUE)
          @osTemplateUrl = nil if (@osTemplateUrl == UNSET_VALUE)
          @imageResourceUrl = nil if( @imageResourceUrl == UNSET_VALUE)
          @newOsPassword = nil if (@newOsPassword == UNSET_VALUE)
          @nodeResourceUrl = nil if (@nodeResourceUrl == UNSET_VALUE)
          @orgResourceUrl = nil if (@orgResourceUrl == UNSET_VALUE)

          if (@ipMappings == UNSET_VALUE || @ipMappings == nil)
            @ipMappings = Array.new
          else
            finalizeIpMappings
          end

        end
        
        
        def finalizeIpMappings

          if(!@ipMappings.empty?)
            
            ipMappingsList = Array.new

            @ipMappings.each do |ipMapping|

              currentIpMapping = IpMapping.new
              currentIpMapping.privateIp = ipMapping[:privateIp]
              currentIpMapping.newPublicIpCount = ipMapping[:newPublicIpCount]
              currentIpMapping.publicIpsFromReserved = ipMapping[:publicIpsFromReserved]

              currentIpMapping.finalize!
              ipMappingsList << currentIpMapping

            end

            @ipMappings = ipMappingsList

          end

        end

      end

    end
  end
end