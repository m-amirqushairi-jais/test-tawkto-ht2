#
# Cookbook:: mongodb
# Recipe:: default
#
# Installs MongoDB, writes its config, and brings up a single-node replica set.

package 'mongodb-org' do
  version node['mongodb']['version']
  action :install
end

directory node['mongodb']['data_dir'] do
  owner 'mongodb'
  group 'mongodb'
  mode  '0750' # task 3: fix 7 - change permissions to 0750 to allow the mongodb user and group to read/write, while preventing access from others for better security.
  recursive true
end

template '/etc/mongod.conf' do
  source 'mongod.conf.erb'
  owner 'root'
  group 'root'
  mode '0640' # task 3: fix 8 - change permissions to 0640 to allow root to read/write the config file while allowing others to read it, but not write, enhancing security.
  notifies :restart, 'service[mongod]', :delayed # task 3: fix 9 - add a notification to restart the mongod service if the configuration file changes, ensuring that any updates to the config are applied immediately.
end

# task 3: fix 10 - to be remove anti pattern of using execute resource for enabling services, we can use the service resource to enable mongod to start on boot, which is more in line with Chef best practices and ensures better idempotency.
# execute 'enable-mongod' do # task 3: fix 5 - rearrange the order of commands to enable the mongod service before starting it, ensuring that the service is set to start on boot before we attempt to start it.
#   command 'systemctl enable mongod'
# end

service 'mongod' do
  action [:enable, :start] # task 3: fix 11 - combine enable and start actions into a single service resource for better readability and efficiency, ensuring that mongod is both enabled to start on boot and started immediately.
end

bash 'init-replica-set' do # task 3: fix 4 - change the command to use mongosh instead of mongo, as mongosh is the newer shell for MongoDB and provides better performance and features. Also, using --quiet to suppress unnecessary output for cleaner logs.
  code <<-EOH
    mongosh --quiet --eval "rs.initiate()"
  EOH
  not_if 'mongosh --quiet --eval "try{rs.status().ok}catch(e){0}" | grep -q 1' # task 3: fix 6 - idempotency check to ensure the replica set is only initialized if it hasn't been already, preventing errors on subsequent runs of the recipe.
end
