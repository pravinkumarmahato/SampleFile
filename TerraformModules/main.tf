module "vpc_vpc-ca1dbeb7" {
  source               = "./modules/vpc"
  vpc_cidr             = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

module "vpc_vpc-03811f75a97cffa86" {
  source               = "./modules/vpc"
  vpc_cidr             = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/VPC"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
  }
}

module "vpc_vpc-07452964709d9cc87" {
  source               = "./modules/vpc"
  vpc_cidr             = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/VPC"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
  }
}

module "vpc_vpc-01824193402915c0a" {
  source               = "./modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Owner"       = "kaiburr"
    "Managed_by"  = "Terraform"
    "Name"        = "kaiburr-sandbox-vpc"
    "Environment" = "sandbox"
  }
}

module "vpc_vpc-0a18e3337585e7f2d" {
  source               = "./modules/vpc"
  vpc_cidr             = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name"                                        = "eksctl-kaiburrEks-cluster/VPC"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
  }
}

module "subnet_subnet-07e509d5bbeb86ee3" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.128.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-0a18e3337585e7f2d.id
  az                      = "us-east-1b"
  tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "Name"                                        = "eksctl-kaiburrEks-cluster/SubnetPrivateUSEAST1B"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
  }
}

module "subnet_subnet-092a04285bc3f6c83" {
  source                  = "./modules/subnet"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-01824193402915c0a.id
  az                      = "us-east-1a"
  tags = {
    "Environment" = "sandbox"
    "Name"        = "kaiburr-sandbox-public-sn-a"
    "Managed_by"  = "Terraform"
    "Owner"       = "kaiburr"
  }
}

module "subnet_subnet-0f6c1a37a7c2ae9ba" {
  source                  = "./modules/subnet"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-01824193402915c0a.id
  az                      = "us-east-1b"
  tags = {
    "Managed_by"  = "Terraform"
    "Name"        = "kaiburr-sandbox-private-sn-b"
    "Environment" = "sandbox"
    "Owner"       = "kaiburr"
  }
}

module "subnet_subnet-0e643c573c7daeac7" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.0.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-07452964709d9cc87.id
  az                      = "us-east-1a"
  tags = {
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "kubernetes.io/role/elb"                      = "1"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/SubnetPublicUSEAST1A"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
  }
}

module "subnet_subnet-03385fcee5457b536" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.160.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-0a18e3337585e7f2d.id
  az                      = "us-east-1c"
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburrEks-cluster/SubnetPrivateUSEAST1C"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "subnet_subnet-0fc0d7d547dade1dc" {
  source                  = "./modules/subnet"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-01824193402915c0a.id
  az                      = "us-east-1b"
  tags = {
    "Managed_by"  = "Terraform"
    "Name"        = "kaiburr-sandbox-public-sn-b"
    "Environment" = "sandbox"
    "Owner"       = "kaiburr"
  }
}

module "subnet_subnet-04300872857f03c3a" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.32.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-03811f75a97cffa86.id
  az                      = "us-east-1b"
  tags = {
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "kubernetes.io/role/elb"                      = "1"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/SubnetPublicUSEAST1B"
  }
}

module "subnet_subnet-0924c7ab5eb22c900" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.64.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-07452964709d9cc87.id
  az                      = "us-east-1c"
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "kubernetes.io/role/elb"                      = "1"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/SubnetPublicUSEAST1C"
  }
}

module "subnet_subnet-0b7f54fd77c59e881" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.0.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-0a18e3337585e7f2d.id
  az                      = "us-east-1a"
  tags = {
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "kubernetes.io/role/elb"                      = "1"
    "Name"                                        = "eksctl-kaiburrEks-cluster/SubnetPublicUSEAST1A"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
  }
}

module "subnet_subnet-08bd3ebf13e6078b3" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.128.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-03811f75a97cffa86.id
  az                      = "us-east-1b"
  tags = {
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/SubnetPrivateUSEAST1B"
    "kubernetes.io/role/internal-elb"             = "1"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
  }
}

module "subnet_subnet-0777c89717e03b99a" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.96.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-07452964709d9cc87.id
  az                      = "us-east-1a"
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "kubernetes.io/role/internal-elb"             = "1"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/SubnetPrivateUSEAST1A"
  }
}

module "subnet_subnet-137b331d" {
  source                  = "./modules/subnet"
  cidr_block              = "172.31.64.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-ca1dbeb7.id
  az                      = "us-east-1f"
}

module "subnet_subnet-05dd600368666de8e" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.128.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-07452964709d9cc87.id
  az                      = "us-east-1b"
  tags = {
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "kubernetes.io/role/internal-elb"             = "1"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/SubnetPrivateUSEAST1B"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
  }
}

module "subnet_subnet-02be2e5a15db5f53b" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.64.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-0a18e3337585e7f2d.id
  az                      = "us-east-1c"
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburrEks-cluster/SubnetPublicUSEAST1C"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "kubernetes.io/role/elb"                      = "1"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
  }
}

module "subnet_subnet-08e5d4685fea3bd4b" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.96.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-0a18e3337585e7f2d.id
  az                      = "us-east-1a"
  tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburrEks-cluster/SubnetPrivateUSEAST1A"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
  }
}

module "subnet_subnet-db518bea" {
  source                  = "./modules/subnet"
  cidr_block              = "172.31.48.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-ca1dbeb7.id
  az                      = "us-east-1e"
}

module "subnet_subnet-06922b7e140c164fb" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.0.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-03811f75a97cffa86.id
  az                      = "us-east-1a"
  tags = {
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/SubnetPublicUSEAST1A"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "kubernetes.io/role/elb"                      = "1"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
  }
}

module "subnet_subnet-00078ca09318815dc" {
  source                  = "./modules/subnet"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-01824193402915c0a.id
  az                      = "us-east-1a"
  tags = {
    "Managed-By" = "Manual"
    "Name"       = "subnet-3"
  }
}

module "subnet_subnet-01c47000df369b6fb" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.96.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-03811f75a97cffa86.id
  az                      = "us-east-1a"
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/SubnetPrivateUSEAST1A"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "subnet_subnet-0625ded7cd9ba3e58" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.32.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-0a18e3337585e7f2d.id
  az                      = "us-east-1b"
  tags = {
    "kubernetes.io/role/elb"                      = "1"
    "Name"                                        = "eksctl-kaiburrEks-cluster/SubnetPublicUSEAST1B"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
  }
}

module "subnet_subnet-0820a8571cea612b4" {
  source                  = "./modules/subnet"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-01824193402915c0a.id
  az                      = "us-east-1a"
  tags = {
    "Name"        = "kaiburr-sandbox-private-sn-a"
    "Environment" = "sandbox"
    "Managed_by"  = "Terraform"
    "Owner"       = "kaiburr"
  }
}

module "subnet_subnet-09e0aa166d38b49a0" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.160.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-03811f75a97cffa86.id
  az                      = "us-east-1c"
  tags = {
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/SubnetPrivateUSEAST1C"
    "kubernetes.io/role/internal-elb"             = "1"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
  }
}

module "subnet_subnet-b11e8390" {
  source                  = "./modules/subnet"
  cidr_block              = "172.31.80.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-ca1dbeb7.id
  az                      = "us-east-1c"
}

module "subnet_subnet-7a57c425" {
  source                  = "./modules/subnet"
  cidr_block              = "172.31.32.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-ca1dbeb7.id
  az                      = "us-east-1a"
}

module "subnet_subnet-0789d52c3f3045e17" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.64.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-03811f75a97cffa86.id
  az                      = "us-east-1c"
  tags = {
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "kubernetes.io/role/elb"                      = "1"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/SubnetPublicUSEAST1C"
  }
}

module "subnet_subnet-911731dc" {
  source                  = "./modules/subnet"
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-ca1dbeb7.id
  az                      = "us-east-1d"
}

module "subnet_subnet-0b30741613af82435" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.32.0/19"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-07452964709d9cc87.id
  az                      = "us-east-1b"
  tags = {
    "Name"                                        = "eksctl-kaiburr-eks-cluster/SubnetPublicUSEAST1B"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "kubernetes.io/role/elb"                      = "1"
  }
}

module "subnet_subnet-0afc6a6c" {
  source                  = "./modules/subnet"
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc_vpc-ca1dbeb7.id
  az                      = "us-east-1b"
}

module "subnet_subnet-0155ddbcf6d005cda" {
  source                  = "./modules/subnet"
  cidr_block              = "192.168.160.0/19"
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc_vpc-07452964709d9cc87.id
  az                      = "us-east-1c"
  tags = {
    "Name"                                        = "eksctl-kaiburr-eks-cluster/SubnetPrivateUSEAST1C"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "kubernetes.io/role/internal-elb"             = "1"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
  }
}

module "nat_gateway_nat-03124bae3c96ec462" {
  source    = "./modules/nat_gateway"
  subnet_id = module.subnet_subnet-06922b7e140c164fb.id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/NATGateway"
  }
}

module "nat_gateway_nat-02219cab44b54bb6d" {
  source    = "./modules/nat_gateway"
  subnet_id = module.subnet_subnet-0fc0d7d547dade1dc.id
  tags = {
    "Environment" = "sandbox"
    "Owner"       = "kaiburr"
    "Managed_by"  = "Terraform"
    "Name"        = "kaiburr-sandbox-nat-gw-b"
  }
}

module "nat_gateway_nat-0f36b6713b247696a" {
  source    = "./modules/nat_gateway"
  subnet_id = module.subnet_subnet-0b7f54fd77c59e881.id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburrEks-cluster/NATGateway"
  }
}

module "nat_gateway_nat-05cd4bbaadf4d0d59" {
  source    = "./modules/nat_gateway"
  subnet_id = module.subnet_subnet-0e643c573c7daeac7.id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/NATGateway"
  }
}

module "nat_gateway_nat-00a0fb1e11af07e01" {
  source    = "./modules/nat_gateway"
  subnet_id = module.subnet_subnet-092a04285bc3f6c83.id
  tags = {
    "Environment" = "sandbox"
    "Owner"       = "kaiburr"
    "Managed_by"  = "Terraform"
    "Name"        = "kaiburr-sandbox-nat-gw-a"
  }
}

module "internet_gateway_igw-0215bdec00ad5feab" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc_vpc-07452964709d9cc87.id
  tags = {
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/InternetGateway"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
  }
}

module "internet_gateway_igw-028572ac3629d2854" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc_vpc-03811f75a97cffa86.id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/InternetGateway"
  }
}

module "internet_gateway_igw-028f77b5e07ff6dbd" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc_vpc-01824193402915c0a.id
  tags = {
    "Environment" = "sandbox"
    "Name"        = "kaiburr-sandbox-igw"
    "Managed_by"  = "Terraform"
    "Owner"       = "kaiburr"
  }
}

module "internet_gateway_igw-0e65dd3b705aa4069" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc_vpc-0a18e3337585e7f2d.id
  tags = {
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburrEks-cluster/InternetGateway"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
  }
}

module "internet_gateway_igw-17a5b36c" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc_vpc-ca1dbeb7.id
}

module "nat_route_table_rtb-0f402c5143c95eb75" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-05cd4bbaadf4d0d59.id
  vpc_id         = module.vpc_vpc-07452964709d9cc87.id
  tags = {
    "Name"                                        = "eksctl-kaiburr-eks-cluster/PrivateRouteTableUSEAST1A"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
  }
}

module "nat_route_table_rtb-0cb0487bb3d371e31" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-02219cab44b54bb6d.id
  vpc_id         = module.vpc_vpc-01824193402915c0a.id
  tags = {
    "Owner"       = "kaiburr"
    "Managed_by"  = "Terraform"
    "Environment" = "sandbox"
  }
}

module "nat_route_table_rtb-0702e297b53c755c2" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-00a0fb1e11af07e01.id
  vpc_id         = module.vpc_vpc-01824193402915c0a.id
  tags = {
    "Owner"       = "kaiburr"
    "Managed_by"  = "Terraform"
    "Environment" = "sandbox"
  }
}

module "nat_route_table_rtb-024f129dbcf626421" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-03124bae3c96ec462.id
  vpc_id         = module.vpc_vpc-03811f75a97cffa86.id
  tags = {
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/PrivateRouteTableUSEAST1C"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
  }
}

module "nat_route_table_rtb-0dbea13d546f4ede6" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-0f36b6713b247696a.id
  vpc_id         = module.vpc_vpc-0a18e3337585e7f2d.id
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburrEks-cluster/PrivateRouteTableUSEAST1B"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
  }
}

module "nat_route_table_rtb-05cc63256aba18e9b" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-0f36b6713b247696a.id
  vpc_id         = module.vpc_vpc-0a18e3337585e7f2d.id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburrEks-cluster/PrivateRouteTableUSEAST1A"
  }
}

module "nat_route_table_rtb-0b7b8113a22090948" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-03124bae3c96ec462.id
  vpc_id         = module.vpc_vpc-03811f75a97cffa86.id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/PrivateRouteTableUSEAST1B"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
  }
}

module "nat_route_table_rtb-0601a2d557c2adf8c" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-05cd4bbaadf4d0d59.id
  vpc_id         = module.vpc_vpc-07452964709d9cc87.id
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/PrivateRouteTableUSEAST1C"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
  }
}

module "nat_route_table_rtb-01403800ddff03862" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-03124bae3c96ec462.id
  vpc_id         = module.vpc_vpc-03811f75a97cffa86.id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/PrivateRouteTableUSEAST1A"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
  }
}

module "nat_route_table_rtb-016cb5663d271d23c" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-0f36b6713b247696a.id
  vpc_id         = module.vpc_vpc-0a18e3337585e7f2d.id
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
    "Name"                                        = "eksctl-kaiburrEks-cluster/PrivateRouteTableUSEAST1C"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
  }
}

module "nat_route_table_rtb-0d95fc94900a4a175" {
  source         = "./modules/nat_route_table"
  nat_gateway_id = module.nat_gateway_nat-05cd4bbaadf4d0d59.id
  vpc_id         = module.vpc_vpc-07452964709d9cc87.id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/PrivateRouteTableUSEAST1B"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
  }
}

module "igw_route_table_rtb-0b208019ff38cd799" {
  source     = "./modules/igw_route_table"
  vpc_id     = module.vpc_vpc-07452964709d9cc87.id
  gateway_id = module.internet_gateway_igw-0215bdec00ad5feab.igw_id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburr-eks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburr-eks-cluster/PublicRouteTable"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-eks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
  }
}

module "igw_route_table_rtb-042c633b40617bee3" {
  source     = "./modules/igw_route_table"
  vpc_id     = module.vpc_vpc-0a18e3337585e7f2d.id
  gateway_id = module.internet_gateway_igw-0e65dd3b705aa4069.igw_id
  tags = {
    "alpha.eksctl.io/cluster-name"                = "kaiburrEks"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburrEks"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "Name"                                        = "eksctl-kaiburrEks-cluster/PublicRouteTable"
  }
}

module "igw_route_table_rtb-f6567f88" {
  source     = "./modules/igw_route_table"
  vpc_id     = module.vpc_vpc-ca1dbeb7.id
  gateway_id = module.internet_gateway_igw-17a5b36c.igw_id
}

module "igw_route_table_rtb-06219139d4aca6dbd" {
  source     = "./modules/igw_route_table"
  vpc_id     = module.vpc_vpc-01824193402915c0a.id
  gateway_id = module.internet_gateway_igw-028f77b5e07ff6dbd.igw_id
  tags = {
    "Environment" = "sandbox"
    "Owner"       = "kaiburr"
    "Managed_by"  = "Terraform"
  }
}

module "igw_route_table_rtb-0909ca83f4c3f313a" {
  source     = "./modules/igw_route_table"
  vpc_id     = module.vpc_vpc-03811f75a97cffa86.id
  gateway_id = module.internet_gateway_igw-028572ac3629d2854.igw_id
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.127.0"
    "Name"                                        = "eksctl-kaiburr-cluster-cluster/PublicRouteTable"
    "alpha.eksctl.io/cluster-name"                = "kaiburr-cluster"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "kaiburr-cluster"
  }
}

module "route_table_association_rtb-0f402c5143c95eb75" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-0777c89717e03b99a.id
  }
  route_table_id = module.nat_route_table_rtb-0f402c5143c95eb75.route_table_id
}

module "route_table_association_rtb-0cb0487bb3d371e31" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-0f6c1a37a7c2ae9ba.id
  }
  route_table_id = module.nat_route_table_rtb-0cb0487bb3d371e31.route_table_id
}

module "route_table_association_rtb-0702e297b53c755c2" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-0820a8571cea612b4.id
  }
  route_table_id = module.nat_route_table_rtb-0702e297b53c755c2.route_table_id
}

module "route_table_association_rtb-024f129dbcf626421" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-09e0aa166d38b49a0.id
  }
  route_table_id = module.nat_route_table_rtb-024f129dbcf626421.route_table_id
}

module "route_table_association_rtb-0dbea13d546f4ede6" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-07e509d5bbeb86ee3.id
  }
  route_table_id = module.nat_route_table_rtb-0dbea13d546f4ede6.route_table_id
}

module "route_table_association_rtb-05cc63256aba18e9b" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-08e5d4685fea3bd4b.id
  }
  route_table_id = module.nat_route_table_rtb-05cc63256aba18e9b.route_table_id
}

module "route_table_association_rtb-0b7b8113a22090948" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-08bd3ebf13e6078b3.id
  }
  route_table_id = module.nat_route_table_rtb-0b7b8113a22090948.route_table_id
}

module "route_table_association_rtb-0601a2d557c2adf8c" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-0155ddbcf6d005cda.id
  }
  route_table_id = module.nat_route_table_rtb-0601a2d557c2adf8c.route_table_id
}

module "route_table_association_rtb-01403800ddff03862" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-01c47000df369b6fb.id
  }
  route_table_id = module.nat_route_table_rtb-01403800ddff03862.route_table_id
}

module "route_table_association_rtb-016cb5663d271d23c" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-03385fcee5457b536.id
  }
  route_table_id = module.nat_route_table_rtb-016cb5663d271d23c.route_table_id
}

module "route_table_association_rtb-0d95fc94900a4a175" {
  source = "./modules/route_table_association"
  subnet_ids = {
    subnet_1 = module.subnet_subnet-05dd600368666de8e.id
  }
  route_table_id = module.nat_route_table_rtb-0d95fc94900a4a175.route_table_id
}

