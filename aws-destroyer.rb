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

#deleting ec2
ec2_client = Aws::EC2::Client.new(creds)
ec2_resource = Aws::EC2::Resource.new(creds)
instance_list = ec2_resource.instances
pp instance_list
instance_list.map{|instance|
  ec2_client.terminate_instances({
    instance_ids: [instance.id]
  })
}

#ELB delete
elb_client = Aws::ElasticLoadBalancing::Client.new(creds)
lb_list = elb_client.describe_load_balancers
pp lb_list
lb_list[:load_balancer_descriptions].map{|load_balancer|
  load_balancer_name = load_balancer.load_balancer_name
  elb_client.delete_load_balancer({load_balancer_name: load_balancer_name})
}
