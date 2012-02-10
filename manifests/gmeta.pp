class ganglia::gmeta {
	

	package { 'gmetad' :
		ensure	=> latest,
	}

	include concat::setup
	include ganglia::common

	$configuration_file = '/etc/ganglia/gmetad.conf'
	$gridname	= ''

	concat{ $configuration_file :
		owner => root,
		group => root,
		mode  => 644
	}

	concat::fragment{ 'main':
		target => $configuration_file,
		content => template('ganglia/gmeta/gmetad.conf.erb'),
		order   => 01,
	}

	define retriever (
		$hosts,
		$polling_interval = 10
	) {

		concat::fragment{ "gmeta-node-${name}":
			target	=> '/etc/ganglia/gmetad.conf',
			order   => 50,
			content	=> template('ganglia/gmeta/retriever.erb')
		}

	}

}