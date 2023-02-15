#!/bin/bash
#
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

set -x
set -e

SetupALB() {
    echo "setting up ALB - target groups - listener"
	instance_id=`curl http://169.254.169.254/latest/meta-data/instance-id`
	instance_private_ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
	mac_id=`curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/`
	instance_vpc_id=`curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac_id}/vpc-id`
	arn_loadbalacer=`aws  elbv2 describe-load-balancers  --region eu-west-1 --query "LoadBalancers[? LoadBalancerName == 'test-alb'].LoadBalancerArn" --output text`
	arn_targetgroup=`aws  elbv2 describe-target-groups --name test-tgt  --region eu-west-1 --query "TargetGroups[? TargetGroupName == 'test-tgt'].TargetGroupArn" --output text`
	aws elbv2 register-targets --target-group-arn "${arn_targetgroup}" --targets Id="${instance_private_ip}" --region "${cfn_region}"
	aws elbv2 create-listener --load-balancer-arn "${arn_loadbalacer}" --protocol HTTPS --port 443 --certificates CertificateArn=arn:aws:acm:eu-west-1:125565990213:certificate/638b0aae-1ed3-4194-b2b1-9b1b57ec3c70 --default-actions Type=forward,TargetGroupArn="${arn_targetgroup}" --region "${cfn_region}"
}

# main
# ----------------------------------------------------------------------------
main() {
    echo "[INFO][$(date '+%Y-%m-%d %H:%M:%S')] 01.alb-target-register.sh: START" >&2
	SetupALB
    echo "[INFO][$(date '+%Y-%m-%d %H:%M:%S')] 01.alb-target-register.sh: STOP" >&2
    
}

main "$@"
