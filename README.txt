
####################################
## SECUREDCLOUD VAGRANT PROVIDERs ##
####################################

This is a Vagrant (http://www.vagrantup.com) 1.2+ plugin that adds a SecuredCloud (http://phoenixnap.com/secured-cloud/) provider to Vagrant, allowing Vagrant to control and provision machines through the SecuredCloud API.

**NOTE:** This plugin requires Vagrant 1.2+,



#########################
## Features
##

- Create and destroy VMs
- Power on and off VMs
- Reboot VMs
- SSH into VMs using password authentication
- Get the current state of the created VMs
- Get the list of available SecuredCloud OS templates from which VMs can be created



#########################
## Usage
##

Install using standard Vagrant 1.1+ plugin installation methods. After installing, use the "vagrant up" command and specify the secured_cloud provider. An example is shown below:


$ vagrant plugin install secured-cloud-vagrant

...

$ vagrant up --provider=secured_cloud

...

Before running the second command, you'll obviously need to add a SecuredCloud-compatible box file to your Vagrant environment. 



#########################
## Server Certificate Validation
##

The supplied certificate file "sc.pem" must be placed in the cert directory of your vagrant workspace. The SecuredCloud Vagrant plugin will use this certificate to perform SSL validation against the SecuredCloud API server.



#########################
## Quick Start
##

After installing the plugin (as indicated in the above section), the quickest way to get started is to use a dummy SecuredCloud box and specify all the required details in the config.vm.provider block in the Vagrantfile. So first add the dummy box as follows:

$ vagrant box add sc_dummy https://github.com/leanneb/secured-cloud-vagrant/raw/master/dummy.box

...


And then make a Vagrantfile that looks like the following, filling in your information where necessary.



	Vagrant.configure('2') do |config|
  		config.vm.box = "sc_dummy"
		
		config.vm.provider :secured_cloud do |sc|
		
			# Authentication info to connect to the SecuredCloud API
			sc.auth.url = "URL TO CONNECT TO THE SECURED CLOUD API"
			sc.auth.applicationKey = "YOUR APPLICATION KEY"
			sc.auth.sharedSecret = "YOUR SHARED SECRET"
		
			# VM details
			sc.vm.name = "vmName"
			sc.vm.storageGB = 16
			sc.vm.memoryMB = 1024
			sc.vm.vcpus = 1
			sc.vm.osTemplateUrl = "OS TEMPLATE RESOURCE URL"
			sc.vm.newOsPassword = "abcdefgh"
			sc.vm.nodeResourceUrl = "NODE RESOURCE URL"
			sc.vm.orgResourceUrl = "YOUR ORGANIZATION RESOURCE URL"
		
		end
	end


And then run vagrant up --provider=secured_cloud

This will start a VM within your organization account on the specified node. Also, assuming that the created VM supports SSH connections, you can also SSH into the VM using password authentication. Unfortunately, provisioning is not supported in the current release.

Please note that since provisioning is not supported, any additional custom scripts defined within the box to be executed during provisioning, will be ignored.



#########################
## Box Format
##

Every provider in Vagrant must introduce a custom box format. This provider introduces secured_cloud boxes. You can view an example box in the example_box/ directory. That directory also contains instructions on how to build a box.

The box format is basically just the required metadata.json file along with a Vagrantfile that does default settings for the provider-specific configuration for this provider which can be overriden by higher-level Vagrantfiles.



#########################
## Configuration
##

The secured_cloud provider exposes a number of provider-specific configuration options as indicated in the following list:

* vm.name 		- The name that the Vagrant-managed VM is to be given on SecuredCloud 
* vm.description	- The description that the Vagrant-managed VM is to be given on SecuredCloud
* vm.storageGB		- The amount of  storage to be allocated to the the VM in GB
* vm.memoryMB		- The amount of memory to be allocated to the VM in MB
* vm.vcpus		- The number of VCPUs to be allocated to the VM
* vm.osTemplateUrl	- The resource URL of the SecuredCloud OS template from which the VM is to be created.
* vm.imageResourceUrl	- The resource URL of the customer image from which the VM is to be created.
* vm.newOsPassword	- The password to be given to the default user of the VM when creating a VM from a SecuredCloud OS template.
* vm.nodeResourceUrl	- The resource URL of the node on which the VM is to be created on SecuredCloud.
* vm.orgResourceUrl	- The resource URL of the organization under which the VM is to be created on SecuredCloud.
* vm.ipMappings		- This is a list of IP mappings representing the IPs to be assigned to the VM where each IP mapping defines a privateIp, newPublicIpCount or publicIpsFromReserved. Please refer to the Examples section for further information on how these should be specified.

* auth.url 		- The SecuredCloud API URL.
* auth.applicationKey 	- The organization's SecuredCloud API application key
* auth.sharedSecret 	- The organization's SecuredCloud API shared secret

**NOTE:** Only one of vm.osTemplateUrl or vm.imageResourceUrl must be specified for each VM in the Vagrantfile.



#########################
## Commands
##

The secured_cloud provider supports the following Vagrant commands:

* vagrant up [vm_name] 						- Creates a powered on VM on SecuredCloud as specified in the Vagrantfile, or powers it on if already created. Should [vm_name] be omitted, all the VMs specified in the Vagrantfile will be created/powered on.
* vagrant destroy [vm_name]					- Powers OFF and destroys the VM from SecuredCloud. Should [vm_name] be omitted, all the VMs specified in the Vagrantfile will be destroyed.
* vagrant halt [vm_name]					- Powers OFF the VM. Should [vm_name] be omitted, all the VMs specified in the Vagrantfile will be halted.
* vagrant reload [vm_name]					- Reboots the VM if ON, or powers it ON when stopped. Should [vm_name] be omitted, all the VMs specified in the Vagrantfile will be reloaded.
* vagrant status						- Outputs the status (running, stopped or not created) of the VM. Should [vm_name] be omitted, the status of all the VMs specified in the Vagrantfile will be displayed.
* vagrant ssh-config [vm_name]					- Outputs the SSH connection details for the VM. The [vm_name] option can only be omitted when the Vagrantfile describes only one VM.
* vagrant ssh							- Opens an SSH connection to the VM using the VM details on SecuredCloud which can in turn be overridden in the Vagrantfile. This command requires the SSH command to be installed if running on a Windows machine. The [vm_name] option can only be omitted when the Vagrantfile describes only one VM.
* vagrant list -t -O [org_resource_url] -N [node_resource_url]	- Outputs the list of available SecuredCloud OS templates from which VMs can be created on the specified node under the specified organization 

Please note that private key authentication is not supported by the secured_cloud provider.



#########################        
## Known Issues
##

The current release of the secured-cloud-vagrant plugin does not support a number of Vagrant features, the details of which can be found in the following subsections.
 


#########################
## Networks
##

Networking features in the form of config.vm.network are not supported with secured-cloud-vagrant, currently. If any of these are specified, Vagrant will emit a warning, but will otherwise boot the VM.



#########################
## Provisioning
##

Provisioning features in the form of config.vm.provision are not currently supported by secured-cloud-vagrant. If any of these are specified, a warning is emitted by Vagrant, but will otherwise create and boot the VM. 



#########################
## Synced Folder
##

Folder syncing features in the form of config.vm.synced_folder are not supported by the secured-cloud-vagrant plugin. If any of these are specified they will be ignored by the secured_cloud provider.



#########################
## VM Suspension
##

Suspension of VMs is not supported in SecuredCloud. For this reason, the vagrant suspend command is not supported by the secured-cloud-vagrant plugin.



#########################
## VM Resume
##

Similarly to VM suspension, the secured_cloud provider does not allow VMs to be resumed. As a result, the vagrant resume command is not supported by the secured-cloud-vagrant plugin. 



#########################
## Examples
##

The secured_cloud provider allows you to specify different configuration options in the Vagrantfile depending on your needs. In this section we provide two example Vagrantfiles: one that manages one VM and another that manages two.



	### Single Machine Example

	Vagrant.configure('2') do |config|

		config.vm.box = "dummy_sc_box"
	
		# SSH settings for the VM can be overriden as follows
		#config.ssh.username = "root"
		#config.ssh.port = 22
		#config.ssh.host = "my-hostname"
	
		config.vm.provider :secured_cloud do |sc|
		
			# Authentication info to connect to the SecuredCloud API
			sc.auth.url = "https://mysecuredcloudapi.com"
			sc.auth.applicationKey = "my_application_key"
			sc.auth.sharedSecret = "my_shared_secret"
		
			# VM details
			sc.vm.name = "vmName"
			sc.vm.storageGB = 16
			sc.vm.memoryMB = 2048
			sc.vm.vcpus = 2
			sc.vm.newOsPassword = "mypassw0rd"
			sc.vm.nodeResourceUrl = "/node/1"
			sc.vm.orgResourceUrl = "/organization/415824"
		
			# This property should be specified if the VM is to be created from a SecuredCloud OS template	
			sc.vm.osTemplateUrl = "/ostemplate/178"
		
			# This property should be specified if the VM is to be created from a customer image
			# sc.vm.imageResourceUrl = "/image/1466"
    
			#This will assign a new public IP to the VM.
			sc.vm.ipMappings = [
				{
					:newPublicIpCount => 1
				}
			]
		
		end
	end




	## Multiple Machines Example

	Vagrant.configure('2') do |config|

		# Configuration settings that are common for all machines
		config.vm.provider :secured_cloud do |sc|
		
			# Authentication info to connect to the SecuredCloud API
			sc.auth.url = "https://mysecuredcloudapi.com"
			sc.auth.applicationKey = "my_application_key"
			sc.auth.sharedSecret = "my_shared_secret"
			
		end

  
		# Configuration for VM 1
		config.vm.define "machine_1" do |machine_1|
	
			machine_1.vm.box = "dummy_sc_box"
				
			# Properties defined for secured_cloud
			machine_1.vm.provider :secured_cloud do |sc|
		
				sc.vm.name = "vagrantVm1"
				sc.vm.description = "Description for vagrantVm1"
				sc.vm.storageGB = 25
				sc.vm.memoryMB = 2048
				sc.vm.vcpus = 2
				sc.vm.newOsPassword = "mypassw0rd01"
				sc.vm.nodeResourceUrl = "/node/1"
				sc.vm.orgResourceUrl = "/organization/415824"
			
				# VM created from OS template
				sc.vm.osTemplateUrl = "/ostemplate/178"
			
				# This will assign private IP 10.2.0.19 to the VM (this is only allowed when running 
				# your org in custom network mode).
				# This will also assign two public IPs to your VM from your org's public IP reserve pool.
				sc.vm.ipMappings = [
					{
						:privateIp => "10.2.0.19",
						:publicIpsFromReserved => ["172.27.21.40", "172.27.21.34"]
					}
				]
						
			end
	
		end
	
	
		# Configuration for VM 2
		config.vm.define "machine_2" do |machine_2|
		
			machine_2.vm.box = "dummy_sc_box"
		
			# Properties defined for secured_cloud
			machine_2.vm.provider :secured_cloud do |sc|
		
				sc.vm.name = "vagrantVm2"
				sc.vm.description = "Description for vagrantVm2"
				sc.vm.storageGB = 50
				sc.vm.memoryMB = 4096
				sc.vm.vcpus = 2
				sc.vm.newOsPassword = "mypassw0rd02"
				sc.vm.nodeResourceUrl = "/node/1"
				sc.vm.orgResourceUrl = "/organization/415824"
			
				# VM created from customer image
				sc.vm.imageResourceUrl = "/image/2796"
			
				# This will assign a new public IP from the global pool and another one from 
				# your org's public IP reserve pool
				sc.vm.ipMappings = [
					{
						:newPublicIpCount => 1,
						:publicIpsFromReserved => "172.27.21.48"
					}
				]
			
			end
	
		end

	end



#########################
## Development
##

To work on the secured-cloud-vagrant plugin, clone this repository out, and use Bundler (http://gembundler.com) to get the dependencies:

$ bundle

Once you have the dependencies, you're ready to start developing the plugin. You can test the plugin without installing it into your Vagrant environment by just creating a Vagrantfile in the top level of this directory (it is gitignored) and add the following line to your Vagrantfile.
 
Vagrant.require_plugin "secured-cloud-vagrant"


Use bundler to execute Vagrant:

$ bundle exec vagrant up --provider=secured_cloud
