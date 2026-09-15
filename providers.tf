provider "aws" {
  region = var.aws_region

  # default_tags applies the standard tag set to every taggable resource the
  # provider creates, so individual resources only declare a Name tag.
  default_tags {
    tags = local.common_tags
  }
}
