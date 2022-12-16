output "cloudwatch_log_group" {
  description = "All outputs from `aws_cloudwatch_log_group.default`"
  value       = aws_cloudwatch_log_group.default
}

output "cloudwatch_log_group_arn" {
  description = "Cloudwatch log group ARN"
  value       = try(aws_cloudwatch_log_group.default[0].arn, "")
}

output "cloudwatch_log_group_name" {
  description = "Cloudwatch log group name"
  value       = try(aws_cloudwatch_log_group.default[0].name, "")
}

output "container_definition" {
  description = "All outputs from `module.container_definition`"
  value       = module.container_definition
  sensitive   = true
}

output "container_definition_json" {
  description = "JSON encoded list of container definitions for use with other terraform resources such as aws_task_definition"
  value       = module.container_definition.json_map_encoded_list
  sensitive   = true
}

output "container_definition_json_map" {
  description = "JSON encoded container definitions for use with other terraform resources such as aws_task_definition"
  value       = module.container_definition.json_map_encoded
  sensitive   = true
}

output "exec_role_policy_id" {
  description = "The ECS execution role policy ID, in the form of `role_name:role_policy_name`"
  value       = module.service_task.exec_role_policy_id
}

output "exec_role_policy_name" {
  description = "The ECS execution role policy name"
  value       = module.service_task.exec_role_policy_name
}

output "service_task" {
  description = "All outputs from `module.service_task`"
  value       = module.service_task
}

output "task_definition_family" {
  description = "The ECS task definition family"
  value       = module.service_task.task_definition_family
}

output "task_definition_revision" {
  description = "The ECS task definition revision"
  value       = module.service_task.task_definition_revision
}

output "task_role_arn" {
  description = "The ECS task role ARN"
  value       = module.service_task.task_role_arn
}

output "task_role_id" {
  description = "The ECS task role id"
  value       = module.service_task.task_role_id
}

output "task_role_name" {
  description = "The ECS task role name"
  value       = module.service_task.task_role_name
}
