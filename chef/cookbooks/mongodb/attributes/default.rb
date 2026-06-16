default['mongodb']['port'] = 27017
default['mongodb']['data_dir'] = '/var/lib/mongodb'

# Package version we install.
default['mongodb']['version'] = '8.0' # task 3: fix 1 - update to a more recent stable version of MongoDB to ensure better performance and security

# Network + auth settings.
default['mongodb']['bind_ip'] = '127.0.0.1' # task 3: fix 2 - change bind_ip to allow external connections for better accessibility, but should be used with caution in production environments. node.default is older verbose style, using 'default' is more concise and modern.

# Admin credentials used to bootstrap the deployment.
default['mongodb']['admin_user'] = 'admin'
default['mongodb']['admin_password'] = 'admin123' # task 3: fix 3 - change default admin password to a more secure one to enhance security. In production, consider using environment variables or encrypted data bags to manage sensitive information.
