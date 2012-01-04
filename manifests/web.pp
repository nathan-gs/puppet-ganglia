class ganglia::web (
	$www_dir = '/var/www/ganglia',
	$version	= 'ganglia-web',
	$conf_dir	= '/etc/ganglia/web.d',
	$view_conf_dir	= '/etc/ganglia/web.conf.d',
	$graph_dir	= '/etc/ganglia/web.graph.d'
) {

	file { $www_dir : 
		source => "puppet:///modules/ganglia/${version}",
		recurse => true,
	}

	file { $conf_dir :
		ensure	=> directory,
		owner 	=> 'root',
		group 	=> 'www-data',
		mode 	=> 750,
		notify	=> [Exec["ganglia-web-sed-version"], Exec["ganglia-web-sed-conf_default"]]
	}

	file { "${www_dir}/conf.php" :
		ensure	=> present,
		owner 	=> root,
		group 	=> www-data,
		mode 	=> 640,
		content	=> template('ganglia/web/conf.php.erb'),
		require	=> [File[$conf_dir], File[$www_dir]]
	}


	exec { "ganglia-web-sed-version" :
        command => 'sed -e s/@GWEB_VERSION@/git/ version.php.in > version.php',
        cwd		=> "${www_dir}",
        timeout => 3600,
    }

	exec { "ganglia-web-sed-conf_default" :
        command => 'sed -e "s/@varstatedir@/\/var\/lib/" conf_default.php.in > conf_default.php',
        cwd		=> "${www_dir}",
        timeout => 3600,
    }

    file { "/var/lib/ganglia/dwoo" :
    	ensure	=> directory,
		owner 	=> 'www-data',
		group 	=> 'www-data',
		mode 	=> 750,
    }

    file { "${view_conf_dir}" :
    	ensure	=> directory,
		owner 	=> 'root',
		group 	=> 'www-data',
		mode 	=> 750,
		source 	=> "puppet:///modules/ganglia/${version}/conf",
		recurse => true,
		replace	=> false,
    }

    file { "${conf_dir}/000-path.php" :
    	content	=> template('ganglia/web/000-path.php.erb'),
    	ensure	=> present,
    	owner 	=> 'root',
		group 	=> 'www-data',
		mode 	=> 640,
		require	=> [File[$conf_dir],File[$view_conf_dir],File[$graph_dir]]
    }

    file { "${graph_dir}" :
    	ensure	=> directory,
		owner 	=> 'root',
		group 	=> 'www-data',
		mode 	=> 750,
		source 	=> "puppet:///modules/ganglia/${version}/graph.d",
		recurse => true,
		replace	=> false,
    }

    package { "rrdtool" :
    	ensure	=> latest,
    }

}