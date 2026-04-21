variable "aws_region"   { default = "us-east-1" }
variable "project_name" { default = "timpay" }
variable "db_password"  {
	type = string
	sensitive = true
}
