resource "azurerm_network_interface" "nic" {
  name                = "book-nic"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "bookipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = var.ip_name
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "bookdevops"
}

resource "azurerm_storage_account" "stor" {
  name                     = "bookstor"
  location                 = "West Europe"
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_windows_virtual_machine" "vm" {
  resource "azurerm_network_interface" "nic" {
  name                = "book-nic"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "bookipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = var.ip_name
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "bookdevops"
}

resource "azurerm_storage_account" "stor" {
  name                     = "bookstor"
  location                 = "West Europe"
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "bookvm"
  location              = "West Europe"
  resource_group_name   = azurerm_resource_group.rg.name
  size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_password = var.password
  admin_username = var.username

  os_disk {
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  winrm_listener {
    protocol = "Http"
  }
  identity {
    type = "SystemAssigned"
  }

  custom_data = filebase64("./files/init-script.ps1")

  additional_unattend_content {
    setting = "AutoLogon"
    content = "<AutoLogon><Password><Value>${var.password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.username}</Username></AutoLogon>"
  }

  additional_unattend_content {
    setting = "FirstLogonCommands"
    content = file("./files/FirstLogonCommands.xml")
  }
  connection {
    host     = azurerm_public_ip.pip.fqdn
    type     = "winrm"
    port     = 5985
    https    = false
    insecure = true
    timeout  = "5m"
    user     = var.username
    password = var.password
  }
  provisioner "file" {
    source      = "files"
    destination = "c:/terraform"
  }

  boot_diagnostics {
    enabled     = true
    storage_account_uri  = azurerm_storage_account.stor.primary_blob_endpoint
  }
}

