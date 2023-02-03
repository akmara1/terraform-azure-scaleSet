variable "name" {}
variable "loc" {}
variable "rg" {}
variable "subnet" {}
variable "backend_pool" {}
variable "nat_pool" {}
variable "list" {
  type = map()
  default = {
    first = {
        dest_port = 80
        priority = 100
    }
    second = {
        dest_port = 22
        priority = 101
    }
  }
}