data "http" "workstation-external-ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

