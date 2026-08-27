data "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "lab" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.lab.location
  resource_group_name = data.azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "lab" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = data.azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "lab" {
  name                = "${var.vm_name}-pip"
  location            = data.azurerm_resource_group.lab.location
  resource_group_name = data.azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Only SSH is exposed. Horizon is reached through an SSH tunnel, never opened
# to the internet: the lab password would be a free ride for anyone scanning.
resource "azurerm_network_security_group" "lab" {
  name                = "${var.vm_name}-nsg"
  location            = data.azurerm_resource_group.lab.location
  resource_group_name = data.azurerm_resource_group.lab.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "lab" {
  name                = "${var.vm_name}-nic"
  location            = data.azurerm_resource_group.lab.location
  resource_group_name = data.azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab.id
  }
}

resource "azurerm_network_interface_security_group_association" "lab" {
  network_interface_id      = azurerm_network_interface.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

# No trusted launch block here on purpose: Trusted Launch disables nested
# virtualization, so the VM stays on the standard security type.
resource "azurerm_linux_virtual_machine" "lab" {
  name                  = var.vm_name
  location              = data.azurerm_resource_group.lab.location
  resource_group_name   = data.azurerm_resource_group.lab.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.lab.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
