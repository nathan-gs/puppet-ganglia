class ganglia::metrics {

	file { "/usr/local/share/ganglia/gmetric" :
		source => "puppet:///modules/ganglia/gmetric",
		recurse => true,
	}

	define gmetric(
		$month    = "*",
		$monthday = "*",
		$hour     = "*",
		$minute
	) {
		cron { "ganglia-gmetric-${name}":
			command  => "/usr/local/share/ganglia/gmetric/${name}",
			user     => "root",
			month    => $month,
			monthday => $monthday,
			hour     => $hour,
			minute   => $minute,
			require 	=> [
				Service['gangia-monitor']
				]
		}
	}
}