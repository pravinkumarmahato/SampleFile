module "aws_lb" {
  source  = "./modules/terraform-aws-ec2-alb"
  tags = {
    "com.kaiburr.needHealthcheckConfiguration" = ""
  }

  alb_name             = "kaiburr-alb"
  target_type          = "instance"
  target_ids           = ["i-0a10691c581e8d588"]
  deregistration_delay = 300
  slow_start           = 0
  enable_http2         = true
  internal             = false
  idle_timeout         = 300

  redirects = {
    redirects_object1 = {
      lb_port             = 80
      lb_protocol         = "HTTP"
      ingress_cidr_blocks = null
      target_port         = 443
      target_protocol     = "HTTPS"
      sg_protocol         = "tcp"
      description         = ""
    }
  }

  listeners = {
    listeners_object1 = {
      lb_port             = 8383
      lb_protocol         = "HTTPS"
      ingress_cidr_blocks = null //not used
      target_port         = 9090
      target_protocol     = "HTTP"
      certificate_arn     = "arn:aws:acm:us-east-1:835181583795:certificate/0731e7d5-e945-46ac-af44-20ee82d5f621"
      sg_protocol         = "tcp"//not used
      ssl_policy          = "ELBSecurityPolicy-2016-08"
      description         = "" 

      health_check_interval            = 60
      health_check_path                = "/"
      health_check_port                = "80"
      health_check_protocol            = "HTTP"
      health_check_timeout             = 30
      health_check_healthy_threshold   = 2
      health_check_unhealthy_threshold = 10
      health_check_matcher             = "200"
    }
  }
  stickness = {
    useStickness = false
    cookie_duration = 86400
  }
}

module "aws_instance" {
  source  = "./modules/terraform-aws-ec2-instance-linux"
 
  tags = {
    "Name"                                  = "kaiburr-vip-jobs-Node"
    "alpha.eksctl.io/nodegroup-name"        = "jobs"
    "alpha.eksctl.io/nodegroup-type"        = "managed"
    "eks:cluster-name"                      = "kaiburr-vip"
    "eks:nodegroup-name"                    = "jobs"
    "k8s.io/cluster-autoscaler/enabled"     = "true"
    "k8s.io/cluster-autoscaler/kaiburr-vip" = "owned"
    "kubernetes.io/cluster/kaiburr-vip"     = "owned"
    "nodegroup-role"                        = "jobs"
  }

  instances = {
    obj = {
      availability_zone     = "us-east-1a"
      iam_instance_profile  = "eks-e4be51b8-d9e9-ce80-347b-bf3d2f2128cf"
      instance_type         = "m5a.2xlarge"
      os_volume_size        = 1
      os_volume_type        = "gp2"
      user_data             = "TUlNRS1WZXJzaW9uOiAxLjAKQ29udGVudC1UeXBlOiBtdWx0aXBhcnQvbWl4ZWQ7IGJvdW5kYXJ5PSIvLyIKCi0tLy8KQ29udGVudC1UeXBlOiB0ZXh0L3gtc2hlbGxzY3JpcHQ7IGNoYXJzZXQ9InVzLWFzY2lpIgojIS9iaW4vYmFzaApzZXQgLWV4CkI2NF9DTFVTVEVSX0NBPUxTMHRMUzFDUlVkSlRpQkRSVkpVU1VaSlEwRlVSUzB0TFMwdENrMUpTVU0xZWtORFFXTXJaMEYzU1VKQlowbENRVVJCVGtKbmEzRm9hMmxIT1hjd1FrRlJjMFpCUkVGV1RWSk5kMFZSV1VSV1VWRkVSWGR3Y21SWFNtd0tZMjAxYkdSSFZucE5RalJZUkZSSmVrMUVSWGxPUkVGNFRrUkJlRTVXYjFoRVZFMTZUVVJGZVUxVVFYaE9SRUY0VGxadmQwWlVSVlJOUWtWSFFURlZSUXBCZUUxTFlUTldhVnBZU25WYVdGSnNZM3BEUTBGVFNYZEVVVmxLUzI5YVNXaDJZMDVCVVVWQ1FsRkJSR2RuUlZCQlJFTkRRVkZ2UTJkblJVSkJUVmx5Q2t0M1VGWlpja0prTVhWb1ptWnRZVFpNTlcxTldFTlJSek5uT0cxaFMwZE9OWG95ZDI1RVpGaGxRaTlTZVVkcmVqUTNiekZ4YnpGcVVISTNha0pZUlcwS1F6ZEthbVJFTWpkT1pUZHJhWHBIVUVsQ1ZHNXRibGt2ZWt4Tk1YUlFhbGhTWVdObk9EWllSazlXY1hFeVFYZExjV1l5Wm05VVdURmhXUzh3UmxaQkt3cHVZa3hZYTBsbmQwWlNha0Z2WVVsWUt6WkpUMVZZTnpONVFpOTJjakZVVjI1a05WUlBWVVYxWkcxR1VuaFVUVGR6YUhkU1RGSTROMHRWYWpSdVpHb3ZDblUxVEc1YVZEaHBRWGRGVWpsb00xYzNSR1Z3TkcxNFEzY3ZhbGQyY3l0Qk5FaFNhMDlCWTJneFdFaG1ZMDFLSzFaNGFrSm1WbTQ1TVZwSWJFTXJTbU1LYVZseWF6Qk9kbk5oY0ZFMWMzUm1iVlZwWW10Q0sxbDJSRmxHYjJKaFVrUk5TVzEzZFVRck9WZEZZV1JWYUZKTlptZzBXSEV5T0RKT1N5OVVNV2xhWkFwQ1dYcHlVWFZOZDBSNmVFSTFLMUpTWkVoVlEwRjNSVUZCWVU1RFRVVkJkMFJuV1VSV1VqQlFRVkZJTDBKQlVVUkJaMHRyVFVFNFIwRXhWV1JGZDBWQ0NpOTNVVVpOUVUxQ1FXWTRkMGhSV1VSV1VqQlBRa0paUlVaTFdGUTNlVll4YmpOaVUyeDNkazl5VURsbWJrcG5jRVJIY2t0TlFUQkhRMU54UjFOSllqTUtSRkZGUWtOM1ZVRkJORWxDUVZGRFNrZFFZVXRSZFdkek9YRjFTWGN2WTJKaU4wcFRlbkp6VDBkeVdVVmphR0ZGUWs1SmREaHpkMjg0VjJ0RmRUbFphUW81T1VGSlZtcEpUekpJWVhKamNrUmxVMFZNU1hsMlFrdzRSMlIyZUN0b1ZESTBaemx3YTJoeVp6VnJaVWw0TUdKTVl6bEdOMHRXV1ZWQmRrTkZNVWcxQ25GM09FTjFWRUV6VDIxd2JuZHdXbFY2V1d4dWVXUlpMMk5GVDBVclEwSmFhWEZYUzI5bWFqSmFaM2wzZVhSV2NrdERUVE16VlZwbUx6aExkRzlpVW5VS2VUaEJSV2RaWjFaSE1XTmxialZzUkhWa1IzZFBWVEJRUTNSVlVGcDRNMk5PU0RaV05uZE5PRWx4YlVsTlUwZFlXbmM0VDNsUFMxVnhSSFl2Vld0cVlRcGtWV1JrVVRKRVF6bFpXVFJQVTBsdmVERnJSRzl0WVhSa1pIbEVMelYwVUhodFZrNUpMMUpuTlZacGJqWnphRWhGTmtGVVlpdHpNVEppYWpoU05raExDbGN3WTBVMllqaDBOekZYVGtKaGVFMUZUMjExWW1FckszWTRNMEpWTVUxTVJHUnBOd290TFMwdExVVk9SQ0JEUlZKVVNVWkpRMEZVUlMwdExTMHRDZz09CkFQSV9TRVJWRVJfVVJMPWh0dHBzOi8vNEIwRTQ4RjNCMDY4NTI5RUE1NjUyNTBBNUE2OEM3MjQuZ3I3LnVzLWVhc3QtMS5la3MuYW1hem9uYXdzLmNvbQpLOFNfQ0xVU1RFUl9ETlNfSVA9MTAuMTAwLjAuMTAKL2V0Yy9la3MvYm9vdHN0cmFwLnNoIGthaWJ1cnItdmlwIC0ta3ViZWxldC1leHRyYS1hcmdzICctLW5vZGUtbGFiZWxzPWVrcy5hbWF6b25hd3MuY29tL3NvdXJjZUxhdW5jaFRlbXBsYXRlVmVyc2lvbj0xLGFscGhhLmVrc2N0bC5pby9jbHVzdGVyLW5hbWU9a2FpYnVyci12aXAsYWxwaGEuZWtzY3RsLmlvL25vZGVncm91cC1uYW1lPWpvYnMscm9sZT1qb2JzLGVrcy5hbWF6b25hd3MuY29tL25vZGVncm91cC1pbWFnZT1hbWktMGVmMDE2YWIyMWQ3MmY0YTEsZWtzLmFtYXpvbmF3cy5jb20vY2FwYWNpdHlUeXBlPU9OX0RFTUFORCxla3MuYW1hem9uYXdzLmNvbS9ub2RlZ3JvdXA9am9icyxla3MuYW1hem9uYXdzLmNvbS9zb3VyY2VMYXVuY2hUZW1wbGF0ZUlkPWx0LTBlYjU5OTRhMjY4YzYxZmJjIC0tbWF4LXBvZHM9NTgnIC0tYjY0LWNsdXN0ZXItY2EgJEI2NF9DTFVTVEVSX0NBIC0tYXBpc2VydmVyLWVuZHBvaW50ICRBUElfU0VSVkVSX1VSTCAtLWRucy1jbHVzdGVyLWlwICRLOFNfQ0xVU1RFUl9ETlNfSVAgLS11c2UtbWF4LXBvZHMgZmFsc2UKCi0tLy8tLQ=="
    }
  }

  ami_id             = "ami-0ef016ab21d72f4a1"
  key_name           = "kaiburr"

  security_group_ids = [
    "eks-cluster-sg-kaiburr-vip-1439533046_sg-0abc0b6ce12a775d7",
    "eksctl-kaiburr-vip-nodegroup-jobs-remoteAccess_sg-0918b751e2ca234a9"
  ]

  ingress_rules = {
    ingress_rules_1 = {
        cidr_blocks = ["172.31.0.0/16"]
        description = "allow from cloudply01"
        from_port   = "0"
        protocol    = "-1"
        self        = "false"
        to_port     = "0"
    },
    ingress_rules_2 = {
        description     = "Allow unmanaged nodes to communicate with control plane (all ports)"
        from_port       = "0"
        protocol        = "-1"
        security_groups = ["sg-0587b4cf19ad20977"]
        self            = "false"
        to_port         = "0"
    },
    ingress_rules_3 = {
        description     = "elbv2.k8s.aws/targetGroupBinding=shared"
        from_port       = "5000"
        protocol        = "tcp"
        security_groups = ["sg-05700a779c3a23c20"]
        self            = "false"
        to_port         = "8080"
    },
    ingress_rules_4 = {
        description     = "elbv2.k8s.aws/targetGroupBinding=shared"
        from_port       = "5000"
        protocol        = "tcp"
        security_groups = ["sg-05700a779c3a23c20"]
        self            = "false"
        to_port         = "8080"
    },
    ingress_rules_5 = {
        from_port       = "0"
        protocol        = "-1"
        security_groups = ["sg-0c9278539961c0b98", "sg-0ebd9bfec07d7b1fd"]
        self            = "true"
        to_port         = "0"
    },
    ingress_rules_6 = {
        cidr_blocks = ["192.168.0.0/16"]
        description = "Allow SSH access to managed worker nodes in group jobs (private, only inside VPC)"
        from_port   = "22"
        protocol    = "tcp"
        self        = "false"
        to_port     = "22"
    }
  }
  egress_rules = {
    egress_rules_1 = {
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = "0"
        protocol    = "-1"
        self        = "false"
        to_port     = "0"
    },
    egress_rules_2 = {
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = "0"
        protocol    = "-1"
        self        = "false"
        to_port     = "0"
    }
  }
}
