#!/usr/bin/sh

OSNAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
servername=$(hostname)

case ${role_name} in
  "General_Linux")
    case $(echo $OSNAME) in
      "Red Hat Enterprise Linux")
        sudo dnf install wget -y
        wget https://cbrecloudvminfra.blob.core.windows.net/chefinfra/Chef_General_AWS_Linux.sh -P /tmp
        sudo sh /tmp/Chef_General_AWS_Linux.sh -e ${environment} -d ${server_domain} -g ${server_admin_group} -r ${role_name} -s $servername
        sudo hostnamectl set-hostname $servername
        sudo reboot
        ;;
      "CentOS Linux" | "Red Hat Enterprise Linux Server")
        sudo yum install wget -y
        wget https://cbrecloudvminfra.blob.core.windows.net/chefinfra/Chef_General_AWS_Linux.sh -P /tmp
        sudo sh /tmp/Chef_General_AWS_Linux.sh -e ${environment} -d ${server_domain} -g ${server_admin_group} -r ${role_name} -s $servername
        sudo hostnamectl set-hostname $servername
        sudo reboot
        ;;
      "Ubuntu" | "Debian GNU/Linux")
        wget https://cbrecloudvminfra.blob.core.windows.net/chefinfra/Chef_General_AWS_Linux.sh -P /tmp
        sh /tmp/Chef_General_AWS_Linux.sh -e ${environment} -d ${server_domain} -g ${server_admin_group} -r ${role_name} -s $servername
        hostnamectl set-hostname $servername
        sudo reboot
        ;;
      "Amazon Linux")
        sudo yum install wget -y
        wget https://cbrecloudvminfra.blob.core.windows.net/chefinfra/Chef_General_AWS_Linux.sh -P /tmp
        sudo sh /tmp/Chef_General_AWS_Linux.sh -e ${environment} -d ${server_domain} -g ${server_admin_group} -r ${role_name} -s $servername
        sudo hostnamectl set-hostname $servername
        sudo reboot
        ;;
      *)
        echo "OS not supported"
        exit 1
        ;;
    esac
    ;;
  "CloudEng")
    case $(echo $OSNAME) in
      "Red Hat Enterprise Linux")
        sudo dnf install wget -y
        wget https://cbrecloudvminfra.blob.core.windows.net/chefinfra/Chef_CloudEng_AWS_Linux.sh -P /tmp
        sudo sh /tmp/Chef_CloudEng_AWS_Linux.sh -e ${environment} -d ${server_domain} -g ${server_admin_group} -r ${role_name} -s $servername
        sudo hostnamectl set-hostname $servername
        sudo reboot
        ;;
      "CentOS Linux" | "Red Hat Enterprise Linux Server")
        sudo yum install wget -y
        wget https://cbrecloudvminfra.blob.core.windows.net/chefinfra/Chef_CloudEng_AWS_Linux.sh -P /tmp
        sudo sh /tmp/Chef_CloudEng_AWS_Linux.sh -e ${environment} -d ${server_domain} -g ${server_admin_group} -r ${role_name} -s $servername
        sudo hostnamectl set-hostname $servername
        sudo reboot
        ;;
      "Ubuntu" | "Debian GNU/Linux")
        wget https://cbrecloudvminfra.blob.core.windows.net/chefinfra/Chef_CloudEng_AWS_Linux.sh -P /tmp
        sh /tmp/Chef_CloudEng_AWS_Linux.sh -e ${environment} -d ${server_domain} -g ${server_admin_group} -r ${role_name} -s $servername
        hostnamectl set-hostname $servername
        sudo reboot
        ;;
      "Amazon Linux")
        sudo yum install wget -y
        wget https://cbrecloudvminfra.blob.core.windows.net/chefinfra/Chef_CloudEng_AWS_Linux.sh -P /tmp
        sudo sh /tmp/Chef_CloudEng_AWS_Linux.sh -e ${environment} -d ${server_domain} -g ${server_admin_group} -r ${role_name} -s $servername
        sudo hostnamectl set-hostname $servername
        sudo reboot
        ;;
      *)
        echo "OS not supported"
        exit 1
        ;;
    esac
    ;;
esac