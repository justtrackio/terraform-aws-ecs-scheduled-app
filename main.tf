locals {
  container_cpu         = var.container_cpu != null ? var.container_cpu : data.aws_ssm_parameter.container_cpu[0].value
  total_cpu             = local.container_cpu + var.log_router_container_cpu
  task_cpu              = var.task_cpu != null ? local.total_cpu > var.task_cpu ? local.total_cpu : var.task_cpu : null
  container_memory      = var.container_memory_reservation != null ? var.container_memory_reservation : data.aws_ssm_parameter.container_memory_reservation[0].value
  total_memory          = local.container_memory + var.log_router_container_memory_reservation
  task_memory           = var.task_memory != null ? local.total_memory > var.task_memory ? local.total_memory : var.task_memory : null
  image_tag             = var.app_image_tag == null ? data.aws_ssm_parameter.container_tag[0].value : var.app_image_tag
  container_definitions = "[${module.container_definition.json_map_encoded}, ${module.container_definition_fluentbit.json_map_encoded}]"
  task_policies         = setunion(var.task_policy_arns, local.default_policies)
  default_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
  port_mappings = length(var.port_mappings) == 0 ? [
    {
      containerPort = var.port_gateway
      hostPort      = var.network_mode == "awsvpc" ? var.port_gateway : 0
      protocol      = "tcp"
    },
    {
      containerPort = var.port_metadata
      hostPort      = var.network_mode == "awsvpc" ? var.port_metadata : 0
      protocol      = "tcp"
    },
    {
      containerPort = var.port_profiling
      hostPort      = var.network_mode == "awsvpc" ? var.port_profiling : 0
      protocol      = "tcp"
    },
  ] : var.port_mappings
  healthcheck = var.healthcheck == null ? {
    command = [
      "CMD-SHELL",
      "wget --spider localhost:${var.port_health}/health || exit 1",
    ]
    retries     = 3
    timeout     = 5
    interval    = 10
    startPeriod = 60
  } : var.healthcheck
}

module "ecs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  label_order = var.label_orders.ecs

  context = module.this.context
}

resource "aws_cloudwatch_log_group" "default" {
  count = var.cloudwatch_log_group_enabled ? 1 : 0

  name              = module.this.id
  tags              = module.this.tags
  retention_in_days = var.log_retention_in_days
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name               = module.ecs_label.id
  container_image              = "${var.app_image_repository}:${local.image_tag}"
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  container_cpu                = var.container_cpu
  start_timeout                = var.container_start_timeout
  stop_timeout                 = var.container_stop_timeout
  healthcheck                  = local.healthcheck
  map_environment              = var.container_map_environment
  port_mappings                = local.port_mappings
  secrets                      = var.secrets
  map_secrets                  = var.map_secrets
  ulimits                      = var.ulimits
  working_directory            = var.working_directory

  log_configuration = {
    logDriver     = var.log_driver
    options       = {}
    secretOptions = null
  }
}

module "container_definition_fluentbit" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name               = "log_router"
  container_image              = "${var.log_router_image_repository}:${var.log_router_image_tag}"
  container_cpu                = var.log_router_container_cpu
  container_memory_reservation = var.log_router_container_memory_reservation
  firelens_configuration = {
    type    = var.log_router_type
    options = var.log_router_options
  }

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = try(aws_cloudwatch_log_group.default[0].name, ""),
      awslogs-region        = module.this.aws_region
      awslogs-stream-prefix = module.this.id
    }
  }

  map_environment = var.log_router_map_environment
}

module "service_task" {
  source  = "justtrackio/ecs-scheduled-task/aws"
  version = "1.3.1"

  container_definition_json = local.container_definitions
  task_count                = var.task_count
  task_cpu                  = local.task_cpu
  task_memory               = local.task_memory
  ecs_cluster_arn           = var.ecs_cluster_arn
  task_policy_arns          = local.task_policies
  task_exec_policy_arns     = local.task_policies
  cloudwatch_event_role_arn = var.cloudwatch_event_policy_arns
  schedule_expression       = var.schedule_expression
  is_enabled                = var.is_enabled
  launch_type               = var.launch_type
  subnet_ids                = var.subnet_ids
  security_groups           = var.security_groups
  network_mode              = var.network_mode
  label_orders              = var.label_orders
  context                   = module.this.context
}
