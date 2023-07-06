variable "VPC_id" {
    default = "aws_vpc.terraform-VPC.id"
  
}

variable "target_group_arn" {
  default = "aws_lb_target_group.terraform-TG.arn"
}