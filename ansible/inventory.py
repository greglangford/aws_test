#!/usr/bin/python

import os
import boto3
import json

aws_access_key_id = None
aws_secret_access_key = None
aws_region_name = None

try:
    aws_access_key_id = os.environ['AWS_ACCESS_KEY_ID']
    aws_secret_access_key = os.environ['AWS_SECRET_ACCESS_KEY']
    aws_region_name = os.environ['AWS_DEFAULT_REGION']
except KeyError as e:
    print "Environment variable not found, check os.environ"

session = boto3.session.Session(aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key, region_name=aws_region_name)
ec2 = session.resource('ec2')

web_instance_ips = []
web_instances = ec2.instances.filter(Filters=[{'Name': 'tag:Class', 'Values':['web-server']}, {'Name': 'instance-state-name', 'Values': ['running']}])

for instance in web_instances:
    web_instance_ips.append(instance.public_ip_address)

print json.dumps({
    'all': {
        'vars': {
            'ansible_ssh_user': 'ubuntu'
        }
    },
    'webserver-nodes': {
        'hosts': web_instance_ips
    }
})
