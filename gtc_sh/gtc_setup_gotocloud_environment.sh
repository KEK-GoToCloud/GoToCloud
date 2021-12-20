#!/bin/bash
#
# Usage:
#  gtc_setup_gotocloud_environment.sh
#
# Arguments & Options:
#   -p                 : Project name (default "`date`session")
#   -v                 : gtc_sh script version (default "00o03o02")
#   -h                 : Help option displays usage
#
# Examples:
#   $ gtc_setup_gotocloud_environment.sh -p protein20211111 -v 00o03o02
#
# Debug Script:
#
#

usage_exit() {
        echo "GoToCloud: Usage $0" 1>&2
        echo "GoToCloud: Exiting(1)..."
        exit 1
}

GTC_SYSTEM_DEBUG_MODE=0
# Check if the number of command line arguments is valid
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] @=$@"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] #=$#"; fi
if [[ $# -gt 4 ]]; then
    echo "GoToCloud: Invalid number of arguments ($#)"
    usage_exit
fi

GTC_SET_PROJECT_NAME=`date "+%Y%m%d"`"session"
GTC_SH_VERSION=00o03o02
# Parse command line arguments
while getopts p:v:h OPT
do
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] OPT=$OPT"; fi
    case "$OPT" in
        p)  GTC_SET_PROJECT_NAME=$OPTARG
            echo "GoToCloud: project name '${GTC_SET_PROJECT_NAME}' is specified"
            ;;
        v)  GTC_SH_VERSION=$OPTARG
            echo "GoToCloud: gtc_sh verion '${GTC_SH_VERSION}' is specified"
            ;;            
        h)  usage_exit
            ;;
        \?) echo "GoToCloud: [GTC_ERROR] Invalid option $OPTARG is specified!"
            usage_exit
            ;;
    esac
done
echo "GoToCloud: Run setup with following settings..."
echo "GoToCloud: Project name         : ${GTC_SET_PROJECT_NAME}"
echo "GoToCloud: gtc_sh script verion : ${GTC_SH_VERSION}"

#Mount the file system /efs
echo "GoToCloud: mounting the file system /efs ..." 
mountpoint -q /efs && {
    df -h
    echo "GoToCloud: /efs is already mounted."
    #echo "GoToCloud: Done"
} || {
    sudo yum -y install amazon-efs-utils
    sudo mkdir /efs
    echo 'fs-0a8524613d2736fb6:/ /efs efs _netdev,noresvport,tls,mounttargetip=10.2.4.117 1 1' | sudo tee -a /etc/fstab
    sudo mount -a || {
        echo "GoToCloud:----------------------------------------------------------------------------------------"
        echo "GoToCloud: [GCT_ERROR] Failed to mount /efs. Please create new cloud9 with correct VPC settings."
        echo "GoToCloud:----------------------------------------------------------------------------------------"
        echo "GoToCloud: Exiting(1)..."
        exit 1
    }
    df -h
    echo "GoToCloud: /efs is mounted."
    #echo "GoToCloud: Done"
} 

#Setup SH directory path
GTC_SET_SH_DIR="/efs/em/gtc_sh_ver"${GTC_SH_VERSION}
# echo "GoToCloud: GTC_SET_SH_DIR=${GTC_SET_SH_DIR}"
if [[ ! -e  ${GTC_SET_SH_DIR} ]]; then
    echo "GoToCloud:----------------------------------------------------------------------------------------------------------------"
	echo "GoToCloud: [GCT_ERROR] ${GTC_SET_SH_DIR} dosen't exit. Please run script again with setting correct version."
	echo "GoToCloud:----------------------------------------------------------------------------------------------------------------"
    echo "GoToCloud: Exiting(1)..."
	exit 1
fi

source ${GTC_SET_SH_DIR}/gtc_utility_dependencies_install.sh 

#Installe jq
gtc_dependency_jq_install
GTC_JQ_INST_STAT=$?

#Installe pcluster
gtc_dependency_pcluster_install
GTC_PCLUSER_INST_STAT=$?

#Installe Node.js
gtc_dependency_node_install
GTC_NODE_INST_STAT=$?

#Check if Service-Linked Role "AWSServiceRoleForEC2Spot" exists
gtc_ec2spotrole_check
GTC_CHECK_SPOTROLL_STAT=$?

#Setup Cloud9 environment 
${GTC_SET_SH_DIR}/gtc_setup_cloud9_environment.sh -p ${GTC_SET_PROJECT_NAME}
GTC_CLOUD9_SETUP_STAT=$?

source /home/ec2-user/.gtc/global_variables.sh

#Create s3 bucket
${GTC_SET_SH_DIR}/gtc_aws_s3_create.sh
GTC_S3_CREATE_STAT=$?

#Create ec2 key pair
${GTC_SET_SH_DIR}/gtc_aws_ec2_create_key_pair.sh
GTC_KEY_CREATE_STAT=$?

#Create config 
${GTC_SET_SH_DIR}/gtc_config_create.sh -s 2400 -m 16
GTC_CONFIG_CREATE_STAT=$?

echo "GoToCloud: "
echo "GoToCloud: Checking config settings... "
cat ~/.parallelcluster/config.yaml
echo "GoToCloud: "
#echo "GoToCloud: Done"

source gtc_utility_global_varaibles.sh 
GTC_S3_NAME=$(gtc_utility_get_s3_name)
GTC_KEY_NAME=$(gtc_utility_get_key_name)
GTC_PROJECT_NAME=$(gtc_utility_get_project_name)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_S3_NAME=${GTC_S3_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_NAME=${GTC_KEY_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PCLUSER_INST_STAT=${GTC_PCLUSER_INST_STAT}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_NODE_INST_STAT=${GTC_NODE_INST_STAT}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_S3_CREATE_STAT=${GTC_S3_CREATE_STAT}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_CREATE_STAT=${GTC_KEY_CREATE_STAT}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_CONFIG_CREATE_STAT=${GTC_CONFIG_CREATE_STAT}"; fi

if [ ${GTC_JQ_INST_STAT} == 0 ]&&[ ${GTC_PCLUSER_INST_STAT} == 0 ]&&[ ${GTC_NODE_INST_STAT} == 0 ]&&[ ${GTC_CLOUD9_SETUP_STAT} == 0 ]&&[ ${GTC_S3_CREATE_STAT} == 0 ]&&[ ${GTC_KEY_CREATE_STAT} == 0 ]&&[ ${GTC_CONFIG_CREATE_STAT} == 0 ]; then
    echo "GoToCloud: -- Overall Results : Success -------------------------------------------------------";
else
    echo "GoToCloud: -- Overall Results : Fail ----------------------------------------------------------";
fi
    echo "GoToCloud: Mount /efs         : Success"
if [[ ${GTC_JQ_INST_STAT} == 0 ]]; then
    echo "GoToCloud: Install jq         : Success";
else 
    echo "GoToCloud: Install jq         : Fail";
fi   
if [[ ${GTC_PCLUSER_INST_STAT} == 0 ]]; then
    echo "GoToCloud: Install pcluster   : Success";
else 
    echo "GoToCloud: Install pcluster   : Fail";
fi
if [[ ${GTC_NODE_INST_STAT} == 0 ]]; then
    echo "GoToCloud: Install node.js    : Success";
else
    echo "GoToCloud: Install node.js    : Fail";
fi
if [[ ${GTC_CHECK_SPOTROLL_STAT} == 0 ]]; then
    echo "GoToCloud: Check EC2Spot Roll : Success";
else
    echo "GoToCloud: Check EC2Spot Roll : Fail";
fi
if [[ ${GTC_CLOUD9_SETUP_STAT} == 0 ]]; then
    echo "GoToCloud: Setup Cloud9 tags  : Success";
else
    echo "GoToCloud: Setup Cloud9 tags  : Fail";
fi
if [[ ${GTC_S3_CREATE_STAT} == 0 ]]; then
    echo "GoToCloud: Create s3 bucket   : Success";
else 
    echo "GoToCloud: Create s3 bucket   : Fail. Project name "${GTC_PROJECT_NAME}" may be invalid or S3 bucket "${GTC_S3_NAME}" exists already. Please set other project name.";  
fi
if [[ ${GTC_KEY_CREATE_STAT} == 0 ]]; then
    echo "GoToCloud: Create key-pair    : Success";
else
    echo "GoToCloud: Create key-pair    : Fail. Key-pair "${GTC_KEY_NAME}" exists already. Please set other project name."; 
fi
if [[ ${GTC_CONFIG_CREATE_STAT} == 0 ]]; then
    echo "GoToCloud: Create config file : Success";
    
else 
    echo "GoToCloud: Create config file : Fail";
fi
echo "GoToCloud: ------------------------------------------------------------------------------------"
echo "GoToCloud: Done!"
