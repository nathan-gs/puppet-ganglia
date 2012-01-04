class ganglia::gmon {
	
	include ganglia::common

	package { 'ganglia-monitor' :
		ensure	=> latest,
	}

	service { 'ganglia-monitor' :
		ensure     => running,
    	enable     => true,
		hasrestart => true,
		hasstatus  => false,
		require		=> [File['/etc/init.d/ganglia-monitor']]
	}

	file { '/etc/init.d/ganglia-monitor' :
		ensure		=> present,
		content	=> template('ganglia/gmon/init.erb'),
		owner	=> root,
		group 	=> root,
		mode	=> 755,
		require	=> Package['ganglia-monitor'],
	}

	file { '/etc/ganglia/gmond.conf' :
		ensure	=> present,
		content	=> template('ganglia/gmon/gmond.conf.erb'),
		owner	=> root,
		group 	=> root,
		mode	=> 644,
		require	=> File['/etc/ganglia/gmon.d'],
		notify	=> Service['ganglia-monitor']
	}

	file { '/etc/ganglia/gmon.d' :
		ensure	=> directory,
		owner	=> root,
		group 	=> root,
		mode	=> 755,
	}

	file { '/etc/ganglia/gmon.d/000-globals.conf' :
		ensure	=> present,
		content	=> template('ganglia/gmon/000-globals.conf.erb'),
		owner	=> root,
		group 	=> root,
		mode	=> 644,
		require	=> File['/etc/ganglia/gmon.d'],
		notify	=> Service['ganglia-monitor']
	}

	define unicast_receive (
		$bind	= '',
		$port	= 8649
	) {

		file { "/etc/ganglia/gmon.d/100-unicast-receive-${name}.conf" :
			ensure	=> present,
			content	=> template('ganglia/gmon/100-unicast-receive.conf.erb'),
			owner	=> root,
			group 	=> root,
			mode	=> 644,
			require	=> File['/etc/ganglia/gmon.d'],
			notify	=> Service['ganglia-monitor']
		}
	}

	define unicast_send (
		$host	= '',
		$port	= 8649
	) {

		if $host == '' {
			$host = $name
		}

		file { "/etc/ganglia/gmon.d/200-unicast-send-${name}.conf" :
			ensure	=> present,
			content	=> template('ganglia/gmon/200-unicast-send.conf.erb'),
			owner	=> root,
			group 	=> root,
			mode	=> 644,
			require	=> File['/etc/ganglia/gmon.d'],
			notify	=> Service['ganglia-monitor']
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
			notify	=> Service['ganglia-monitor']
		}
	}

	file { '/etc/ganglia/gmon.d/300-modules.conf' :
		ensure	=> present,
		content	=> template('ganglia/gmon/300-modules.conf.erb'),
		owner	=> root,
		group 	=> root,
		mode	=> 644,
		require	=> [File['/etc/ganglia/gmon.d'], File['/usr/lib/ganglia/python_modules'], File['/etc/ganglia/gmon.python.d']],
		notify	=> Service['ganglia-monitor']
	}

	file { '/usr/lib/ganglia/python_modules' :
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

	ganglia::gmon::unicast_receive { 'local' :
		bind	=> '127.0.0.1'
	}

	ganglia::gmon::unicast_send { 'local' :
		host	=> 'localhost'
	}

}