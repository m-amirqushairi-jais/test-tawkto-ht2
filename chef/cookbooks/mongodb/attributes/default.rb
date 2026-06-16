default['mongodb']['port'] = 27017
default['mongodb']['data_dir'] = '/var/lib/mongodb'

# Package version we install.
default['mongodb']['version'] = '8.0' # task 3: fix 1 - update to a more recent stable version of MongoDB to ensure better performance and security

# Network + auth settings.
default['mongodb']['bind_ip'] = '127.0.0.1' # task 3: fix 2 - restrict bind_ip to localhost; 0.0.0.0 was exposing MongoDB on all network interfaces

# Admin credentials used to bootstrap the deployment.
default['mongodb']['admin_user'] = 'admin'
default['mongodb']['admin_password'] = 'CHANGEME' # improvement 10 - placeholder that forces operator to supply real credentials via Chef Vault or encrypted data bag; never use in production
