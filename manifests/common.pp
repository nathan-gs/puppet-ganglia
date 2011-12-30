class ganglia::common {
	
	user { "ganglia":
		comment => "Ganglia",
		home => "/var/lib/ganglia",
		ensure => present,
		shell => "/bin/false",
		uid => '200',
		gid => '200'
	}


	group { $username:
        gid     => 200,
        require => User[$username]
    }
}