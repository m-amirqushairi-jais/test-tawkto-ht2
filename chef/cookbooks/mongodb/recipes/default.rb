#
# Cookbook:: mongodb
# Recipe:: default
#
# Installs MongoDB, writes its config, and brings up a single-node replica set.

apt_repository 'mongodb' do # improvement 9 - adds the official MongoDB repo before package install; without this apt has no source to find mongodb-org
  uri          "https://repo.mongodb.org/apt/ubuntu"
  distribution "#{node['lsb']['codename']}/mongodb-org/#{node['mongodb']['version']}"
  components   ['multiverse']
  key          "https://www.mongodb.org/static/pgp/server-#{node['mongodb']['version']}.asc"
  action       :add
end

package 'mongodb-org' do
  version node['mongodb']['version']
  action  :install
end

directory node['mongodb']['data_dir'] do
  owner     'mongodb'
  group     'mongodb'
  mode      '0750'
  recursive true
end

template '/etc/mongod.conf' do
  source   'mongod.conf.erb'
  owner    'root'
  group    'mongodb'
  mode     '0640'
  notifies :restart, 'service[mongod]', :delayed
end

service 'mongod' do
  action [:enable, :start]
end

# Guard with not_if to prevent AlreadyInitialized error on subsequent Chef runs.
bash 'init-replica-set' do
  code <<-EOH
    mongosh --quiet --eval "rs.initiate()"
  EOH
  not_if 'mongosh --quiet --eval "try{rs.status().ok}catch(e){0}" | grep -q 1'
end
