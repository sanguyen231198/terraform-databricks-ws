data "azurerm_databricks_workspace" "adb-ws" {
  name                = "sadhgdhsgd-adb"
  resource_group_name = "lhtanadb-rg"
}

data "databricks_group" "users" {
  display_name = "G_Azure_Databricks_Users"
}

data "databricks_group" "admins" {
  display_name = "G_Azure_Infra_Admin"
}

data "azurerm_key_vault" "kv" {
  name                = "lhtanadb-kv"
  resource_group_name = "lhtanadb-rg"
}

data "azurerm_key_vault_secret" "kv-secret" {
  name         = "secret-sauce"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "databricks_current_user" "me" {
}

data "databricks_notebook" "encrytion" {
  path   = "${data.databricks_current_user.me.home}/test/ETL1/cluster-encryption-init-script"
  format = "SOURCE"
}

data "databricks_spark_version" "latest" {}

data "databricks_node_type" "smallest" {
  local_disk = true
}