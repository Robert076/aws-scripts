#!/bin/bash

# Get all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[*].RegionName" --output text)

for region in $regions; do
  echo "=============================="
  echo "Region: $region"
  echo "=============================="

  echo "-- EC2 Instances --"
  aws ec2 describe-instances --region $region \
    --query "Reservations[*].Instances[*].InstanceId" --output text

  echo "-- EBS Volumes --"
  aws ec2 describe-volumes --region $region \
    --query "Volumes[*].VolumeId" --output text

  echo "-- Snapshots (Owned) --"
  aws ec2 describe-snapshots --region $region --owner-ids self \
    --query "Snapshots[*].SnapshotId" --output text

  echo "-- Security Groups --"
  aws ec2 describe-security-groups --region $region \
    --query "SecurityGroups[*].GroupId" --output text

  echo "-- Key Pairs --"
  aws ec2 describe-key-pairs --region $region \
    --query "KeyPairs[*].KeyName" --output text

  echo "-- Elastic IPs --"
  aws ec2 describe-addresses --region $region \
    --query "Addresses[*].PublicIp" --output text

  echo "-- AMIs (Owned) --"
  aws ec2 describe-images --owners self --region $region \
    --query "Images[*].ImageId" --output text

  echo "-- Network Interfaces --"
  aws ec2 describe-network-interfaces --region $region \
    --query "NetworkInterfaces[*].NetworkInterfaceId" --output text

  echo "-- Load Balancers (Classic/ALB/NLB) --"
  aws elb describe-load-balancers --region $region \
    --query "LoadBalancerDescriptions[*].LoadBalancerName" --output text 2>/dev/null

  aws elbv2 describe-load-balancers --region $region \
    --query "LoadBalancers[*].LoadBalancerName" --output text 2>/dev/null

  echo "-- Auto Scaling Groups --"
  aws autoscaling describe-auto-scaling-groups --region $region \
    --query "AutoScalingGroups[*].AutoScalingGroupName" --output text

  echo "-- Launch Templates --"
  aws ec2 describe-launch-templates --region $region \
    --query "LaunchTemplates[*].LaunchTemplateName" --output text

  echo
done
