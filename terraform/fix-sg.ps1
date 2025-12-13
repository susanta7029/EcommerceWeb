# Add port 80 ingress rule to slave security group
$masterSg = "sg-00e30d26754986c34"
$slaveSg = "sg-0e0a4aa4bc616e26d"

Write-Host "Adding HTTP (port 80) ingress rule to slave security group..."

# Using AWS CLI Python wrapper
python -m awscli ec2 authorize-security-group-ingress `
    --group-id $slaveSg `
    --ip-permissions "IpProtocol=tcp,FromPort=80,ToPort=80,UserIdGroupPairs=[{GroupId=$masterSg}]"

Write-Host "Security group rule added successfully!"
