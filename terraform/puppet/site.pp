# Puppet manifest for slave node configuration
# This file defines the configuration for all slave nodes

node default {
  
  # Ensure system is up to date
  exec { 'apt-update':
    command => '/usr/bin/apt-get update',
  }

  # Install NRPE and Nagios plugins
  package { 'nagios-nrpe-server':
    ensure  => installed,
    require => Exec['apt-update'],
  }

  package { 'nagios-plugins':
    ensure  => installed,
    require => Exec['apt-update'],
  }

  package { 'nagios-plugins-basic':
    ensure  => installed,
    require => Exec['apt-update'],
  }

  package { 'nagios-plugins-standard':
    ensure  => installed,
    require => Exec['apt-update'],
  }

  # Install monitoring utilities
  package { ['sysstat', 'bc']:
    ensure  => installed,
    require => Exec['apt-update'],
  }

  # Create memory check script
  file { '/usr/local/bin/check_mem.sh':
    ensure  => file,
    mode    => '0755',
    content => @(MEMSCRIPT)
      #!/bin/bash
      # Memory usage check script
      USED_MEM=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
      TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
      USED_MEM_MB=$(free -m | awk 'NR==2{print $3}')
      
      echo "Memory: ${USED_MEM_MB}MB used of ${TOTAL_MEM}MB (${USED_MEM}%)"
      
      if (( $(echo "$USED_MEM > 90" | bc -l) )); then
          exit 2  # Critical
      elif (( $(echo "$USED_MEM > 80" | bc -l) )); then
          exit 1  # Warning
      else
          exit 0  # OK
      fi
      | MEMSCRIPT
  }

  # Create CPU check script
  file { '/usr/local/bin/check_cpu.sh':
    ensure  => file,
    mode    => '0755',
    content => @(CPUSCRIPT)
      #!/bin/bash
      # CPU usage check script
      CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
      
      echo "CPU Usage: ${CPU_USAGE}%"
      
      if (( $(echo "$CPU_USAGE > 90" | bc -l) )); then
          exit 2  # Critical
      elif (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
          exit 1  # Warning
      else
          exit 0  # OK
      fi
      | CPUSCRIPT
  }

  # Configure NRPE service
  service { 'nagios-nrpe-server':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nagios/nrpe.cfg'],
    require   => Package['nagios-nrpe-server'],
  }

  # NRPE configuration file
  file { '/etc/nagios/nrpe.cfg':
    ensure  => file,
    mode    => '0644',
    owner   => 'nagios',
    group   => 'nagios',
    content => template('nrpe/nrpe.cfg.erb'),
    require => Package['nagios-nrpe-server'],
    notify  => Service['nagios-nrpe-server'],
  }

  # Ensure sysstat is enabled
  file_line { 'enable_sysstat':
    path    => '/etc/default/sysstat',
    line    => 'ENABLED="true"',
    match   => '^ENABLED=',
    require => Package['sysstat'],
  }

  # Restart sysstat service
  service { 'sysstat':
    ensure    => running,
    enable    => true,
    subscribe => File_line['enable_sysstat'],
    require   => Package['sysstat'],
  }
}

# Specific configuration for slave-1
node 'slave-1' {
  include default
  
  notify { 'Configuring Slave Node 1':
    message => 'This is slave node 1',
  }
}

# Specific configuration for slave-2
node 'slave-2' {
  include default
  
  notify { 'Configuring Slave Node 2':
    message => 'This is slave node 2',
  }
}
