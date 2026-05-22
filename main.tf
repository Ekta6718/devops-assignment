module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source = "./modules/security"

  vpc_id = module.vpc.vpc_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "alb" {
  source = "./modules/alb"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security.alb_sg_id
}

module "ecs" {
  source = "./modules/ecs"

  private_subnets  = module.vpc.private_subnets
  ecs_sg_id        = module.security.ecs_sg_id
  target_group_arn = module.alb.target_group_arn
}