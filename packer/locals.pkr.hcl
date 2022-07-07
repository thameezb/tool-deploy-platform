locals {
  tags = {
    environment   = var.environment
    business-unit = "retail"
    owner         = var.team_name
    application   = "gitlab" # This is temporary
    project       = var.project_name
    deployer      = var.deployer_name
    region        = var.region
  }
}
