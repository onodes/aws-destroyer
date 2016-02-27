require 'aws-sdk'
require 'json'
require 'pp'

#importing aws accounts from aws-accounts.json
aws_accounts_file = './aws-accounts.json'
aws_accounts = open(aws_accounts_file) do |io|
  JSON.load(io)
end

#initialize aws accounts
ACCESS_ID = aws_accounts["ACCESS_ID"]
SECRET_ACCESS_KEY = aws_accounts["SECRET_ACCESS_KEY"]
REGION = aws_accounts["REGION"]
credentials = Aws::Credentials.new(ACCESS_ID, SECRET_ACCESS_KEY)
creds = {region: REGION, credentials: credentials}

#deleting ec2 instances
ec2_client = Aws::EC2::Client.new(creds)
ec2_resource = Aws::EC2::Resource.new(creds)
instance_list = ec2_resource.instances
pp instance_list
instance_list.map{|instance|
  ec2_client.terminate_instances({
    instance_ids: [instance.id]
  })
}

#deleting nat gateways
elb_client = Aws::ElasticLoadBalancing::Client.new(creds)
lb_list = elb_client.describe_load_balancers
pp lb_list
lb_list[:load_balancer_descriptions].map{|load_balancer|
  load_balancer_name = load_balancer.load_balancer_name
  elb_client.delete_load_balancer({load_balancer_name: load_balancer_name})
}

#deleting nat gateways
nat_gateways = ec2_client.describe_nat_gateways
nat_gateways.nat_gateways.map{|nat_gateway|
  ec2_client.delete_nat_gateway({
    nat_gateway_id: nat_gateway[:nat_gateway_id]
  })
}

#deleting internet gateways
internet_gateways = ec2_client.describe_internet_gateways
internet_gateways.internet_gateways.map{|internet_gateway|
  ec2_client.detach_internet_gateway({
    internet_gateway_id: internet_gateway.internet_gateway_id,
    vpc_id: internet_gateway.attachments.first.vpc_id
  })

  ec2_client.delete_internet_gateway({
    internet_gateway_id: internet_gateway.internet_gateway_id
  })
}

#deleting elastic ips
elastic_ip_list = ec2_client.describe_addresses
elastic_ip_list.map{|elastic_ip|
  addresses = elastic_ip.addresses
  unless addresses.nil? then
    allocation_id = addresses.first.allocation_id
    ec2_client.release_address({
      allocation_id: allocation_id
      })
  end
}
