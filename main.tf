provider "aws" {
  region = "ap-southeast-2"
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "cluster" {
  name = "fargate-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "fargate-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode(
      [
          {
              "name" : "latest",
              "image" : "915270456781.dkr.ecr.ap-southeast-2.amazonaws.com/nodejs:latest",
              "essential" : true,
              "portMappings" : [
                  {
                      "containerPort" : 80,
                      "hostPort" : 80,
                      "protocol" : "tcp"
                  }
              ]
          }
      ]
  )
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

