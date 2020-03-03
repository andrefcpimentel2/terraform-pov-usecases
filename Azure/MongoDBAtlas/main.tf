resource "mongodbatlas_cluster" "az_cluster" {
  project_id   = var.mongodb_projectid
  name         = "azurecluster"
  num_shards   = 1

  replication_factor           = 3
  backup_enabled               = true
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = "4.0"

  //Provider Settings "block"
  provider_name               = "AZURE"  
  provider_disk_type_name     = "P6"
  provider_instance_size_name = "M0"
  provider_region_name        = "UK_WEST_1"
}