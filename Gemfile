source 'https://rubygems.org'

# Specify your gem's dependencies in secured-cloud-vagrant.gemspec
gemspec

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem "vagrant", :path => "../vagrant-1.4.0"
  #gem "secured_cloud_api_client", :path => "../secured_cloud_api_client"
end