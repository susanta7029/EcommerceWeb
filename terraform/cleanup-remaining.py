import boto3
import time

ec2 = boto3.client('ec2', region_name='us-east-1')
ec2_resource = boto3.resource('ec2', region_name='us-east-1')

print("Cleaning up remaining resources...\n")

# Get VPC
vpcs = ec2.describe_vpcs(
    Filters=[{'Name': 'tag:Name', 'Values': ['master-slave-infra-vpc']}]
)

if vpcs['Vpcs']:
    vpc_id = vpcs['Vpcs'][0]['VpcId']
    vpc = ec2_resource.Vpc(vpc_id)
    
    # Delete route tables
    print("Deleting route tables...")
    for rt in vpc.route_tables.all():
        try:
            # Disassociate all subnets first
            for association in rt.associations:
                if not association.main:
                    association.delete()
                    print(f"  ✓ Disassociated route table association: {association.id}")
            
            # Only delete non-main route tables
            is_main = any(a.main for a in rt.associations)
            if not is_main:
                rt.delete()
                print(f"  ✓ Deleted route table: {rt.id}")
        except Exception as e:
            print(f"  Note: {e}")
    
    # Small delay to ensure dependencies are cleared
    time.sleep(2)
    
    # Delete VPC
    print("\nDeleting VPC...")
    try:
        vpc.delete()
        print(f"✓ Deleted VPC: {vpc_id}")
    except Exception as e:
        print(f"✗ Could not delete VPC: {e}")
        print("\nPlease check AWS Console for any remaining resources:")
        print(f"  - VPC ID: {vpc_id}")
else:
    print("No VPC found - all resources have been destroyed!")

print("\n✓ Cleanup complete!")
