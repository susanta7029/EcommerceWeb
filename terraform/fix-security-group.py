import boto3

# Initialize EC2 client
ec2 = boto3.client('ec2', region_name='us-east-1')

master_sg = 'sg-00e30d26754986c34'
slave_sg = 'sg-0e0a4aa4bc616e26d'

try:
    response = ec2.authorize_security_group_ingress(
        GroupId=slave_sg,
        IpPermissions=[
            {
                'IpProtocol': 'tcp',
                'FromPort': 80,
                'ToPort': 80,
                'UserIdGroupPairs': [{'GroupId': master_sg}]
            }
        ]
    )
    print("✓ Successfully added port 80 ingress rule to slave security group")
    print(f"  Allows traffic from master SG ({master_sg}) to slave SG ({slave_sg})")
except Exception as e:
    if 'already exists' in str(e).lower():
        print("✓ Port 80 rule already exists in slave security group")
    else:
        print(f"✗ Error: {e}")
