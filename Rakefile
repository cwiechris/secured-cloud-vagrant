require 'rubygems'
require 'bundler/setup'
require 'rake/packagetask'

# Immediately sync all stdout so that tools like buildbot can
# immediately load in the output.
$stdout.sync = true
$stderr.sync = true

# Change to the directory of this file.
Dir.chdir(File.expand_path("../", __FILE__))

# This installs the tasks that help with gem creation and
# publishing.
Bundler::GemHelper.install_tasks

# Install the package task
Rake::PackageTask.new("secured-cloud-vagrant-plugin", :noversion) do |p|
  p.need_zip = true
  p.zip_command = '7z a -tzip secured-cloud-vagrant-plugin.zip lib/*.rb'
  p.package_files.include("lib/*.rb")
end