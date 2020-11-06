# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = var.location

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
	    name 			            = "AllowHTTPJenkins"
	    priority		            = 200
	    direction		            = "Inbound"
	    access 			            = "Allow"
	    protocol 		            = "Tcp"
	    source_port_range           = "*"
        destination_port_range     	= "8080"
        source_address_prefix      	= "Internet"
        destination_address_prefix 	= "*"
    }

    security_rule {
	    name 			            = "AllowHTTP"
	    priority		            = 201
	    direction		            = "Inbound"
	    access 			            = "Allow"
	    protocol 		            = "Tcp"
	    source_port_range           = "*"
        destination_port_range     	= "80"
        source_address_prefix      	= "*"
        destination_address_prefix 	= "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}












resource "azurerm_virtual_machine" "jenkins" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
  vm_size               = var.vm_size

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "openLogic"
    offer = "CentOS"
    sku = "7.3"
    version = "latest"
  }

  storage_os_disk {
    name          = "jenkins-osdisk"
    vhd_uri       = "${azurerm_storage_account.jenkins_storage.primary_blob_endpoint}${azurerm_storage_container.jenkins_cont.name}/osdisk-1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = var.os_name
    admin_username = var.vm_username
    admin_password = var.vm_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  depends_on = [azurerm_network_interface_security_group_association.example, azurerm_network_interface.myterraformnic]

}


resource "azurerm_virtual_machine_extension" "jenkins_terraform" {
  name                 = "jenkins_extension"
  virtual_machine_id   = azurerm_virtual_machine.jenkins.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
        "commandToExecute": "wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war",
        "commandToExecute": "sudo yum install java-1.8.0-openjdk -y",
        "commandToExecute": "sudo yum install git -y",
        "commandToExecute": "java -jar jenkins.war"
      }
SETTINGS
}




