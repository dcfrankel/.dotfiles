#!/usr/bin/env zsh
## A sane set of default overrides and customizations for the AWS CLI
## Designed to be easily piped to downstream processes

# Add shared commands defaults to the list
SHARED_AWS_CLI_SUFFIX=(--no-cli-pager --output text)

# Get AWS instances with:
# InstanceID
# Name
# PrivateIpAddress
# State
# SubnetId
function aws-instances() {
  aws ec2 describe-instances --query 'Reservations[*].Instances[*].{instance_id: InstanceId, name: Tags[?Key==`Name`] | [0].Value, ip_address: PrivateIpAddress, state: State.Name, sub_net: SubnetId}' "${SHARED_AWS_CLI_SUFFIX[@]}"
}

# Get AWS subnets with:
# SubnetId
# Name
# CidrBlock
# AvailabilityZone
function aws-subnets() {
  aws ec2 describe-subnets --query 'Subnets[*].{subnet: SubnetId, name: Tags[?Key==`Name`]  | [0].Value, cidr: CidrBlock, az: AvailabilityZone}' "${SHARED_AWS_CLI_SUFFIX[@]}"
}

# Get AWS EBS volumes with:
# VolumeID
# InstanceID
# State
function aws-ebs-volumes() {
  aws ec2 describe-volumes --query "Volumes[*].{volume_id:Attachments[0].VolumeId,instance_id:Attachments[0].InstanceId,state:Attachments[0].State}" "${SHARED_AWS_CLI_SUFFIX[@]}"
}

# Get AWS Parameter Store Parameters with:
# Name
# Type
# DataType
function aws-store-parameters() {
  aws ssm describe-parameters --query "Parameters[*].{name:Name,type:Type,data_type:DataType}" "${SHARED_AWS_CLI_SUFFIX[@]}"
}
