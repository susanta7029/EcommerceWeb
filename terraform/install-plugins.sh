#!/bin/bash
set -e

echo "Installing Nagios Plugins..."
cd /tmp
PLUGIN_VERSION="2.4.6"
wget -q https://github.com/nagios-plugins/nagios-plugins/archive/release-${PLUGIN_VERSION}.tar.gz
tar xzf release-${PLUGIN_VERSION}.tar.gz
cd nagios-plugins-release-${PLUGIN_VERSION}

./tools/setup
./configure
make
sudo make install

echo "Installing NRPE plugin..."
cd /tmp
wget -q https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.1.0/nrpe-4.1.0.tar.gz
tar xzf nrpe-4.1.0.tar.gz
cd nrpe-4.1.0
./configure
make check_nrpe
sudo make install-plugin

echo "Setting permissions and starting Nagios..."
sudo chown -R nagios:nagios /usr/local/nagios

# Restart services
sudo systemctl restart apache2
sudo systemctl enable nagios
sudo systemctl start nagios

echo "Nagios started successfully!"
echo "Access at: http://34.205.2.4/nagios"
echo "Username: nagiosadmin"
echo "Password: admin123"
