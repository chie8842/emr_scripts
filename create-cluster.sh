#!/bin/bash

EC2_ATTRIBUTES=$(cat << EOS
{
  "KeyName": "",
  "InstanceProfile": "",
  "ServiceAccessSecurityGroup": "",
  "SubnetId": "",
  "EmrManagedSlaveSecurityGroup": "",
  "EmrManagedMasterSecurityGroup": "",
  "AdditionalMasterSecurityGroups": [
    "sg-4f08442b"
  ]
}
EOS
)

INSTANCE_GROUPS=$(cat << 'EOS'
[
  {
    "InstanceCount": 2,
    "EbsConfiguration": {
      "EbsBlockDeviceConfigs": [
        {
          "VolumeSpecification": {
            "SizeInGB": 32,
            "VolumeType": "gp2"
          },
          "VolumesPerInstance": 1
        }
      ]
    },
    "InstanceGroupType": "CORE",
    "InstanceType": "c4.2xlarge",
    "Name": "Core - 2"
  },
  {
    "InstanceCount": 1,
    "InstanceGroupType": "MASTER",
    "InstanceType": "m3.xlarge",
    "Name": "Master - 1"
  }
]
EOS
)

CONFIGURATIONS=$(cat <<EOS
[
  {
    "Classification": "spark-env",
    "Properties": {},
    "Configurations": [
      {
        "Classification": "export",
        "Properties": {
          "PYSPARK_PYTHON": "python34"
        },
        "Configurations": []
      }
    ]
  },
  {
    "Classification": "spark-defaults",
    "Properties": {
      "spark.executorEnv.PYTHONHASHSEED": "0"
    },
    "Configurations": []
  }
]
EOS
)

BOOTSTRAP_ACTIONS=$(cat <<EOS
[
  {
    "Path": "s3://[bucket_name]/emr_settings/bootstrap.sh",
    "Name": "Custom action"
  }
]
EOS
)

LOG_URI='s3n://[log_bucket]/elasticmapreduce/'
BOOTSTRAP_ACTION_PATH='s3://[s3_bucket]/emr_settings/bootstrap.sh'
CONFIGURATIONS_PATH='file://software_settings.json'

aws emr create-cluster \
  --applications Name=Hadoop Name=Zeppelin Name=Spark Name=Ganglia \
  --ec2-attributes \
    KeyName=ml,InstanceProfile=EMR_EC2_DefaultRole,ServiceAccessSecurityGroup=xxx,SubnetId=xxx,EmrManagedSlaveSecurityGroup=xxx,EmrManagedMasterSecurityGroup=xxx,AdditionalMasterSecurityGroups=xxx \
  --release-label emr-5.10.0 \
  --log-uri ${LOG_URI} \
  --instance-groups \
    InstanceGroupType=MASTER,InstanceType=m3.xlarge,InstanceCount=1 \
    InstanceGroupType=CORE,InstanceType=c4.2xlarge,InstanceCount=10 \
  --configurations ${CONFIGURATIONS_PATH} \
  --auto-scaling-role EMR_AutoScaling_DefaultRole \
  --bootstrap-actions Path=${BOOTSTRAP_ACTION_PATH},Name=PySparkSettings \
  --ebs-root-volume-size 10 \
  --service-role EMR_DefaultRole \
  --enable-debugging \
  --name 'chie-test' \
  --scale-down-behavior TERMINATE_AT_TASK_COMPLETION \
  --region ap-northeast-1

