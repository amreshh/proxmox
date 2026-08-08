variable "github_token" {
  type        = string
  description = "GitHub token"
  sensitive   = true
}

variable "age_key" {
  type        = string
  description = "Encryption key for secrets"
  sensitive   = true
}
