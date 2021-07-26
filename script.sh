#!/bin/bash
#aws ecr start-image-scan --repository-name loge-hellowworld --image-id imageTag=LATEST
#aws ecr describe-image-scan-findings --repository-name loge-helloworld --image-id imageTag=LATEST
aws ecr wait image-scan-complete --repository-name loge-helloworld --image-id imageTag=LATEST
if [ $(echo $?) -eq 0 ]; then
  SCAN_FINDINGS=$(aws ecr describe-image-scan-findings --repository-name loge-helloworld --image-id imageTag=LATEST | jq '.imageScanFindings.findingSeverityCounts')
  CRITICAL=$(echo $SCAN_FINDINGS | jq '.CRITICAL')
  HIGH=$(echo $SCAN_FINDINGS | jq '.HIGH')
  MEDIUM=$(echo $SCAN_FINDINGS | jq '.MEDIUM')
  LOW=$(echo $SCAN_FINDINGS | jq '.LOW')
  INFORMATIONAL=$(echo $SCAN_FINDINGS | jq '.INFORMATIONAL')
  UNDEFINED=$(echo $SCAN_FINDINGS | jq '.UNDEFINED')
  if [ $CRITICAL != null ] || [ $HIGH != null ]; then
    echo Docker image contains vulnerabilities at CRITICAL or HIGH level
    aws ecr batch-delete-image --repository-name loge-helloworld --image-ids imageTag=LATEST  #delete pushed image from container registry
    exit 1  #exit execution due to docker image vulnerabilities
  fi
fi
