module "example" {
  source = "../.."

  name                        = "hello-world"
  app_image_repository        = "hello-world"
  app_image_tag               = "latest"
  log_router_image_repository = "fluent/fluent-bit"
  log_router_image_tag        = "1.9"
  ecs_cluster_arn             = "arn:aws:ecs:eu-central-1:123456789123:cluster/my-cluster"
  schedule_expression         = "cron(* * * * ? *)"
  aws_region                  = "eu-central-1"
}
