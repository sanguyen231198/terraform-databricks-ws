provider "databricks" {
  host = data.azurerm_databricks_workspace.adb-ws.workspace_url
}

####SECRET####

resource "databricks_secret_scope" "app" {
  name = "app-secret-scope"
}

resource "databricks_secret_acl" "admin_secret_acl" {
  principal  = data.databricks_group.admins.display_name
  permission = "MANAGE"
  scope      = databricks_secret_scope.app.name
}

resource "databricks_secret_acl" "dev_secret_acl" {
  principal  = data.databricks_group.users.display_name
  permission = "READ"
  scope      = databricks_secret_scope.app.name
}

resource "databricks_secret" "publishing_api" {
  key          = "publishing_api"
  string_value = data.azurerm_key_vault_secret.kv-secret.value
  scope        = databricks_secret_scope.app.name
}

####FOLDER####

resource "databricks_directory" "this" {
  path = "/Users/nttsa@trustbasevn.onmicrosoft.com/test/ETL1"
}

resource "databricks_permissions" "folder_usage" {
  directory_path = databricks_directory.this.path
  depends_on     = [databricks_directory.this]

  access_control {
    group_name       = data.databricks_group.admins.display_name
    permission_level = "CAN_MANAGE"
  }

  access_control {
    group_name       = data.databricks_group.users.display_name
    permission_level = "CAN_RUN"
  }
}

####NOTEBOOK####

resource "databricks_permissions" "notebook_usage" {
  notebook_path = data.databricks_notebook.encrytion.path

  access_control {
    group_name       = data.databricks_group.admins.display_name
    permission_level = "CAN_MANAGE"
  }

  access_control {
    group_name       = data.databricks_group.users.display_name
    permission_level = "CAN_MANAGE"
  }
}

####FILE####

resource "databricks_workspace_file" "this" {
  source = "module.py"
  path   = "${data.databricks_current_user.me.home}/test/ETL1/module"
}

resource "databricks_permissions" "workspace_file_usage" {
  workspace_file_path = databricks_workspace_file.this.path

  access_control {
    group_name       = data.databricks_group.admins.display_name
    permission_level = "CAN_MANAGE"
  }

  access_control {
    group_name       = data.databricks_group.users.display_name
    permission_level = "CAN_EDIT"
  }
}

####REPO####

resource "databricks_repo" "this" {
  url = "https://github.com/sanguyen231198/terraform-databricks-ws.git"
}

resource "databricks_permissions" "repo_usage" {
  repo_id = databricks_repo.this.id

  access_control {
    group_name       = data.databricks_group.admins.display_name
    permission_level = "CAN_MANAGE"
  }

  access_control {
    group_name       = data.databricks_group.users.display_name
    permission_level = "CAN_EDIT"
  }
}

####CLUSTER####

# resource "databricks_cluster" "shared_autoscaling" {
#   cluster_name            = "Shared Autoscaling"
#   spark_version           = data.databricks_spark_version.latest.id
#   node_type_id            = data.databricks_node_type.smallest.id
#   autotermination_minutes = 60
#   autoscale {
#     min_workers = 1
#     max_workers = 10
#   }
# }

# resource "databricks_permissions" "cluster_usage" {
#   cluster_id = databricks_cluster.shared_autoscaling.id

#   access_control {
#     group_name       = data.databricks_group.users.display_name
#     permission_level = "CAN_RESTART"
#   }

#   access_control {
#     group_name       = data.databricks_group.admins.display_name
#     permission_level = "CAN_MANAGE"
#   }
# }

####POOL####

# resource "databricks_instance_pool" "this" {
#   instance_pool_name                    = "Reserved Instances"
#   idle_instance_autotermination_minutes = 60
#   node_type_id                          = data.databricks_node_type.smallest.id
#   min_idle_instances                    = 0
#   max_capacity                          = 10
# }

# resource "databricks_permissions" "pool_usage" {
#   instance_pool_id = databricks_instance_pool.this.id

#   access_control {
#     group_name       = data.databricks_group.users.display_name
#     permission_level = "CAN_ATTACH_TO"
#   }

#   access_control {
#     group_name       = data.databricks_group.admins.display_name
#     permission_level = "CAN_MANAGE"
#   }
# }

# ####JOB####

# resource "databricks_job" "this" {
#   name                = "Featurization"
#   max_concurrent_runs = 1

#   new_cluster {
#     num_workers   = 1
#     spark_version = data.databricks_spark_version.latest.id
#     node_type_id  = data.databricks_node_type.smallest.id
#   }

#   notebook_task {
#     notebook_path = data.databricks_notebook.encrytion.path
#   }
# }

# resource "databricks_permissions" "job_usage" {
#   job_id = databricks_job.this.id

#   access_control {
#     group_name       = data.databricks_group.admins.display_name
#     permission_level = "CAN_MANAGE"
#   }

#   access_control {
#     group_name       = data.databricks_group.users.display_name
#     permission_level = "CAN_VIEW"
#   }
# }

####DELTA LIVE TABLES####

# resource "databricks_permissions" "dlt_usage" {
#   pipeline_id = ""

#   access_control {
#     group_name       = data.databricks_group.users.display_name
#     permission_level = "CAN_VIEW"
#   }

#   access_control {
#     group_name       = data.databricks_group.admins.display_name
#     permission_level = "CAN_MANAGE"
#   }
# }

####ALERT####

# resource "databricks_sql_endpoint" "this" {
#   name             = "Endpoint of ${data.databricks_current_user.me.alphanumeric}"
#   cluster_size     = "Small"
#   max_num_clusters = 1
# }

# resource "databricks_sql_query" "this" {
#   data_source_id = databricks_sql_endpoint.this.data_source_id
#   name           = "My Query Name"
#   query          = "SELECT 1 AS p1, 2 as p2"
#   parent         = "folders/${databricks_directory.this.object_id}"
# }

# resource "databricks_sql_alert" "alert" {
#   query_id = databricks_sql_query.this.id
#   name     = "My Alert"
#   parent   = "folders/${databricks_directory.this.object_id}"
#   rearm    = 1
#   options {
#     column = "p1"
#     op     = "=="
#     value  = "2"
#     muted  = false
#   }
# }

# resource "databricks_permissions" "endpoint_usage" {
#   sql_alert_id = databricks_sql_alert.alert.id

#   access_control {
#     group_name       = data.databricks_group.users.display_name
#     permission_level = "CAN_RUN"
#   }

#   access_control {
#     group_name       = data.databricks_group.admins.display_name
#     permission_level = "CAN_MANAGE"
#   }
# }


