class ganglia::gmeta {
	

	package { 'gmetad' :
		ensure	=> latest,
	}

	include concat::setup
	include ganglia::common

	$configuration_file = '/etc/ganglia/gmetad.conf'


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
		$host = '',
		$polling_interval = 10
	) {
		if $host == '' {
			$host = $name
		}

		concat::fragment{ "gmeta-node-${name}":
			target	=> $configuration_file,
			order   => 50,
			content	=> 'data_soure "${cluster}" ${polling_interval} ${host}\n'
		}

	}

}