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
		$cluster = 'main',
		$real_host = '',
		$polling_interval = 10
	) {
		if $real_host == '' {
			$host = $name
		} else {
			$host = $real_host
		}

		concat::fragment{ "gmeta-node-${name}":
			target	=> '/etc/ganglia/gmetad.conf',
			order   => 50,
			content	=> 'data_soure "${cluster}" ${polling_interval} ${host}\n'
		}

	}

}