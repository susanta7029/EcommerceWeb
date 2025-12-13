import boto3
import time

# Initialize AWS clients
ec2 = boto3.client('ec2', region_name='us-east-1')
ec2_resource = boto3.resource('ec2', region_name='us-east-1')

print("=" * 60)
print("DESTROYING AWS INFRASTRUCTURE")
print("=" * 60)

# Get all instances with our project tag
try:
    instances_response = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:Name', 'Values': ['master-slave-infra-*']},
            {'Name': 'instance-state-name', 'Values': ['running', 'stopped', 'pending', 'stopping']}
        ]
    )
    
    instance_ids = []
    for reservation in instances_response['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])
            print(f"Found instance: {instance['InstanceId']} ({instance.get('Tags', [{}])[0].get('Value', 'Unknown')})")
    
    if instance_ids:
        print(f"\n→ Terminating {len(instance_ids)} EC2 instances...")
        ec2.terminate_instances(InstanceIds=instance_ids)
        print("✓ Termination initiated")
        
        # Wait for instances to terminate
        print("  Waiting for instances to terminate (this may take a few minutes)...")
        waiter = ec2.get_waiter('instance_terminated')
        waiter.wait(InstanceIds=instance_ids)
        print("✓ All instances terminated")
    else:
        print("No instances found to terminate")
    
    # Delete key pair
    try:
        ec2.delete_key_pair(KeyName='master-slave-infra-key')
        print("\n✓ Deleted key pair: master-slave-infra-key")
    except Exception as e:
        if 'does not exist' not in str(e).lower():
            print(f"  Warning: Could not delete key pair: {e}")
    
    # Get VPC
    vpcs = ec2.describe_vpcs(
        Filters=[{'Name': 'tag:Name', 'Values': ['master-slave-infra-vpc']}]
    )
    
    if vpcs['Vpcs']:
        vpc_id = vpcs['Vpcs'][0]['VpcId']
        vpc = ec2_resource.Vpc(vpc_id)
        print(f"\n→ Cleaning up VPC: {vpc_id}")
        
        # Delete security groups (except default)
        print("  Deleting security groups...")
        for sg in vpc.security_groups.all():
            if sg.group_name != 'default':
                try:
                    # Remove all rules first
                    if sg.ip_permissions:
                        sg.revoke_ingress(IpPermissions=sg.ip_permissions)
                    if sg.ip_permissions_egress:
                        sg.revoke_egress(IpPermissions=sg.ip_permissions_egress)
                    sg.delete()
                    print(f"  ✓ Deleted security group: {sg.group_name}")
                except Exception as e:
                    print(f"  Warning: {e}")
        
        # Detach and delete internet gateway
        print("  Deleting internet gateways...")
        for igw in vpc.internet_gateways.all():
            try:
                vpc.detach_internet_gateway(InternetGatewayId=igw.id)
                igw.delete()
                print(f"  ✓ Deleted internet gateway: {igw.id}")
            except Exception as e:
                print(f"  Warning: {e}")
        
        # Delete route table associations and route tables
        print("  Deleting route tables...")
        for rt in vpc.route_tables.all():
            if not rt.associations_attribute or not any(a.get('Main') for a in rt.associations_attribute):
                try:
                    rt.delete()
                    print(f"  ✓ Deleted route table: {rt.id}")
                except Exception as e:
                    print(f"  Warning: {e}")
        
        # Delete subnets
        print("  Deleting subnets...")
        for subnet in vpc.subnets.all():
            try:
                subnet.delete()
                print(f"  ✓ Deleted subnet: {subnet.id}")
            except Exception as e:
                print(f"  Warning: {e}")
        
        # Delete VPC
        print("  Deleting VPC...")
        try:
            vpc.delete()
            print(f"✓ Deleted VPC: {vpc_id}")
        except Exception as e:
            print(f"  Warning: {e}")
    else:
        print("\nNo VPC found with tag 'master-slave-infra-vpc'")
    
    print("\n" + "=" * 60)
    print("INFRASTRUCTURE DESTRUCTION COMPLETE")
    print("=" * 60)
    print("\nAll AWS resources have been removed.")
    print("You can safely delete the terraform/ directory if needed.")

except Exception as e:
    print(f"\n✗ Error during destruction: {e}")
    print("\nYou may need to manually check and delete remaining resources in AWS Console.")
