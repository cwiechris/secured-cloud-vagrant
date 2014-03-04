require "pathname"

require "secured-cloud-vagrant/plugin"

module VagrantPlugins
    module SecuredCloud
	
		lib_path = Pathname.new(File.expand_path("../secured-cloud-vagrant", __FILE__))
		autoload :Action, lib_path.join("action")
		#autoload :Errors, lib_path.join("errors")

		# This returns the path to the source of this plugin.
		#
		# @return [Pathname]
		def self.source_root
			@source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
		end
		
		I18n.load_path << File.expand_path("locales/en.yml", source_root)
		
    end
end
