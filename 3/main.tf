terraform {
  required_providers {
    vmworkstation = {
      source = "elsudano/vmworkstation"
      version = "1.0.3"
    }
  }
}
resource "vmworkstation_vm" "test_machine" {
  sourceid     = var.vmws_reource_frontend_sourceid
  denomination = var.vmws_reource_frontend_denomination
  description  = var.vmws_reource_frontend_description
  path         = var.vmws_reource_frontend_path
  processors   = var.vmws_reource_frontend_processors
  memory       = var.vmws_reource_frontend_memory
}