module "ssm_label" {
  source  = "justtrackio/label/null"
  version = "0.26.0"

  delimiter   = "/"
  label_order = var.label_orders.ssm

  context = module.this.context
}

data "aws_ssm_parameter" "container_cpu" {
  count = var.container_cpu == null ? 1 : 0
  name  = "/${module.ssm_label.id}/resources/requests/cpu"
}

data "aws_ssm_parameter" "container_memory_reservation" {
  count = var.container_memory_reservation == null ? 1 : 0
  name  = "/${module.ssm_label.id}/resources/requests/memory"
}

data "aws_ssm_parameter" "container_tag" {
  count = var.app_image_tag == null ? 1 : 0
  name  = "/${module.ssm_label.id}/container_tag"
}
