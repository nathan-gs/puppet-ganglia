class ganglia::gmon {
	
	include ganglia::common

    $package_name = $operatingsystem ? {
        /(Fedora|CentOS)/       => ganglia-gmond,
        default                 => ganglia-monitor
    }

    $service_name = $operatingsystem ? {
        /(Fedora|CentOS)/       => gmond,
        default                 => ganglia-monitor
    }

    $lib_dir = $operatingsystem ? {
       /(Fedora|CentOS)/       => '/usr/lib64/ganglia',
       default                 => '/usr/lib/ganglia',
    }

	package { $package_name :
		ensure	=> latest,
	}

	service { $service_name :
		ensure      => running,
    	enable      => true,
		hasrestart  => true,
		hasstatus   => true,
		require	    => $operatingsystem ? {
            /(Debian|Ubuntu)/   => File["/etc/init.d/${service_name}"],
            default             => [],
        }
    }

    case $operatingsystem {
        /(Fedora|CentOS)/   : {
            package { 'ganglia-gmond-python':
                ensure  => latest,
            }
        }
        /(Debian|Ubuntu)/   : {
            file { '/etc/init.d/ganglia-monitor' :
                ensure		=> present,
                content	=> template('ganglia/gmon/init.erb'),
                owner	=> root,
                group 	=> root,
                mode	=> 755,
                require	=> Package[$package_name],
            }
        }
    }


	file { '/etc/ganglia/gmond.conf' :
		ensure	=> present,
		content	=> template('ganglia/gmon/gmond.conf.erb'),
		owner	=> root,
		group 	=> root,
		mode	=> 644,
		require	=> File['/etc/ganglia/gmon.d'],
		notify	=> Service[$service_name]
	}

	file { '/etc/ganglia/gmon.d' :
		ensure	=> directory,
		owner	=> root,
		group 	=> root,
		mode	=> 755,
		require	=> Package[$package_name]
	}

	file { '/etc/ganglia/gmon.d/000-globals.conf' :
		ensure	=> present,
		content	=> template('ganglia/gmon/000-globals.conf.erb'),
		owner	=> root,
		group 	=> root,
		mode	=> 644,
		require	=> File['/etc/ganglia/gmon.d'],
		notify	=> Service[$service_name]
	}

	define unicast_receive (
		$bind	= '',
		$port	= 8649,
		$family	= 'inet4'
	) {

		file { "/etc/ganglia/gmon.d/100-unicast-receive-${name}.conf" :
			ensure	=> present,
			content	=> template('ganglia/gmon/100-unicast-receive.conf.erb'),
			owner	=> root,
			group 	=> root,
			mode	=> 644,
			require	=> File['/etc/ganglia/gmon.d'],
			notify	=> Service[$ganglia::gmon::service_name]
		}
	}

	define unicast_send (
		$host	= '',
		$port	= 8649
	) {

		if $host == '' {
			$real_host = $name
		} else {
			$real_host = $host
		}

		file { "/etc/ganglia/gmon.d/200-unicast-send-${name}.conf" :
			ensure	=> present,
			content	=> template('ganglia/gmon/200-unicast-send.conf.erb'),
			owner	=> root,
			group 	=> root,
			mode	=> 644,
			require	=> File['/etc/ganglia/gmon.d'],
			notify	=> Service[$ganglia::gmon::service_name]
		}
		
	}

	define tcp_accept (
		$bind	= '',
		$port	= 8649,
		$family	= 'inet4'
	) {

		file { "/etc/ganglia/gmon.d/101-tcp-accept-${name}.conf" :
			ensure	=> present,
			content	=> template('ganglia/gmon/101-tcp-accept.conf.erb'),
			owner	=> root,
			group 	=> root,
			mode	=> 644,
			require	=> File['/etc/ganglia/gmon.d'],
			notify	=> Service[$ganglia::gmon::service_name]
		}
	}

	define cluster (
		$owner
	) {
		file { '/etc/ganglia/gmon.d/001-cluster.conf' :
			ensure	=> present,
			content	=> template('ganglia/gmon/001-cluster.conf.erb'),
			owner	=> root,
			group 	=> root,
			mode	=> 644,
			require	=> File['/etc/ganglia/gmon.d'],
			notify	=> Service[$ganglia::gmon::service_name]
		}
	}

	file { '/etc/ganglia/gmon.d/300-modules.conf' :
		ensure	=> present,
		content	=> template('ganglia/gmon/300-modules.conf.erb'),
		owner	=> root,
		group 	=> root,
		mode	=> 644,
		require	=> [File['/etc/ganglia/gmon.d'], File["${lib_dir}/python_modules"], File['/etc/ganglia/gmon.python.d']],
		notify	=> Service[$service_name]
	}

	file { "${lib_dir}/python_modules" :
		ensure	=> directory,
		owner	=> root,
		group 	=> root,
		mode	=> 755,
	}

	file { '/etc/ganglia/gmon.python.d' :
		ensure	=> directory,
		owner	=> root,
		group 	=> root,
		mode	=> 755,
	}

}