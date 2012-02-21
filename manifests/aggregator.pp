define ganglia::aggregator (
	clustername 	= '',
	hosts			= ''
) {
	
	include ganglia::common

	user { "ganglia-pa":
		comment => "Ganglia Proxy & Aggregator",
		home => "/home/ganglia-pa",
		ensure => present,
		uid => '201',
		#gid => '20'
	}

	service { 'ganglia-proxy-aggregator' :
		ensure     => running,
    	enable     => true,
		hasrestart => true,
		hasstatus  => true,
		require		=> [File['/etc/init.d/ganglia-proxy-aggregator']]
	}

	file { '/etc/init.d/ganglia-proxy-aggregator' :
		ensure		=> present,
		content	=> "ganglia/proxy-aggregator/ganglia-proxy-aggregator.init",
		owner	=> root,
		group 	=> root,
		mode	=> 755,
		require	=> File['/etc/default/ganglia-proxy-aggregator'],
	}

	file { '/etc/default/ganglia-proxy-aggregator' :
		ensure	=> present,
		content	=> template('ganglia/aggregator/default-config.erb'),
		owner	=> root,
		group 	=> root,
		mode	=> 755,
		notify	=> Service['ganglia-proxy-aggregator']
	}
}