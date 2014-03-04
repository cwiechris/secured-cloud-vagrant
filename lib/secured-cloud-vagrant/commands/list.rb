require "vagrant"
require "log4r"
require "pathname"
require "secured_cloud_api_client"

module VagrantPlugins
  module SecuredCloud
    module Command
      class List < Vagrant.plugin(2, :command)

        @logger = Log4r::Logger.new('vagrant::secured_cloud::command::list')

        alias super_parse_options :parse_options
        def self.synopsis
          "Returns a list of OS templates from which VMs can be created\n\t\t  " +
          "by a particular given organization on the specified node"
        end

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant list [-O org_resource_url] [-N node_resource_url] [-t]"
            o.separator ""

            o.on("-t", "--os_templates", "Retrieve OS templates") do |t|
              options[:os_templates] = t
            end

            # o.on("-c", "--customer_images", "Retrieve customer images") do |c|
            # options[:customer_images] = c
            # end

            o.on("-O org_resource_url", "The organization resource for which OS " +
              "templates \n\t\t\t\t     or customer images are to be retrieved.") do |org|
              options[:orgResource] = org
            end

            o.on("-N node_resource_url", "The node resource for which OS templates " +
              "or\n\t\t\t\t     customer images are to be retrieved.") do |n|
              options[:nodeResource] = n
            end
          end

          argv = parse_options(opts, options)
          return if !argv

          authInfo = nil

          with_target_vms(argv) do |machine|
            authInfo = machine.provider_config.auth
          end

          if (options[:os_templates])

            os_templates = get_os_templates(authInfo, options)
            
            # If the OS templates is nil it means that the call was not successful
            return 1 if(os_templates.nil?)
             
            variables = {
              :os_templates => os_templates 
            }

            # Render the template and output directly to STDOUT
            templates_root = Pathname.new(File.expand_path("../../../../templates", __FILE__))
            template = templates_root.join("os_templates")
            safe_puts(Vagrant::Util::TemplateRenderer.render(template, variables))

          end

          # Success, exit status 0
          0

        end
        

        # Parses the options passed in by the user
        def parse_options(opts, options)

          begin

            argv = super_parse_options(opts)

            raise OptionParser::MissingArgument if options[:orgResource].nil?
            raise OptionParser::MissingArgument if options[:nodeResource].nil?
            raise OptionParser::MissingArgument if options[:os_templates].nil? && options[:customer_images].nil?

            return argv

          rescue OptionParser::MissingArgument
            raise Vagrant::Errors::CLIInvalidOptions, :help => opts.help.chomp
          end

        end

        # Returns a list of OS templates for the given options
        def get_os_templates(authInfo, options)

          @logger.debug("Getting OS templates ...")
          
          os_templates = nil

          # If the authentication information is not specified in the Vagrantfile return a failure status
          if(authInfo.nil? || authInfo.url.nil? || authInfo.applicationKey.nil? || authInfo.sharedSecret.nil?)
            @env.ui.error(I18n.t('secured_cloud_vagrant.errors.unspecified_auth', :resource_type => "OS templates"))
            return os_templates
          end

          begin

            # Create a Secured Cloud Connection instance to connect to the SecuredCloud API
            sc_connection = SecuredCloudConnection.new(authInfo.url, authInfo.applicationKey, authInfo.sharedSecret)

            # Get the OS templates for the specified details
            os_templates_urls = SecuredCloudRestClient.getOsTemplatesAvailable(sc_connection, options[:orgResource], options[:nodeResource])

            if !os_templates_urls.nil?

              # Create an array to hold the os templates details
              os_templates = Hash.new

              # Get the details for each retrieved os template resource URL and add it to the list
              os_templates_urls.each do |os_template_url|
                os_templates[os_template_url] = SecuredCloudRestClient.getOsTemplateDetails(sc_connection, os_template_url)
              end

              @logger.debug("Found #{os_templates.length} OS templates for organization '#{options[:orgResource]}' on node '#{options[:nodeResource]}'")

            else

              @logger.debug("No OS templates available for organization '#{options[:orgResource]}' on node '#{options[:nodeResource]}'")

            end

          rescue Errno::ETIMEDOUT
            @env.ui.error(I18n.t("secured_cloud_vagrant.errors.request_timed_out", :request => "get the OS templates details"))
          rescue Exception => e
            @env.ui.error(I18n.t("secured_cloud_vagrant.errors.generic_error", :error_message => e.message))
          end

          return os_templates

        end

      end
    end
  end
end