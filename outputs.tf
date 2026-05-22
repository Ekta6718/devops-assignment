output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "jenkins_master_ip" {
  value = module.jenkins.jenkins_master_public_ip
}

output "jenkins_agent_ip" {
  value = module.jenkins.jenkins_agent_private_ip
}