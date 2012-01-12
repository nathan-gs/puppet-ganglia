class ganglia::metrics::lm-sensors {

	include ganglia::metrics
	
	#source https://github.com/ghoneycutt/puppet-lmsensors

	# only do stuff if this is a real machine and not virtualized
    # note: under qemu virtual => physical and lm_sensors has no effect
    # though it is installed. At Linode.com virtual => xenu and does
    # not work and should not be installed
    case $virtual {
        physical: {
            case $productname {
                # systems that do not use KVM have productname blank
                default: {
                    package { "lm_sensors":
                        notify => Exec["/usr/sbin/sensors-detect"],
                    } # package

                    exec { "/usr/sbin/sensors-detect":
                        command     => "/usr/bin/yes YES | /usr/sbin/sensors-detect > /var/local/sensors-detect",
                        require     => Package["lm_sensors"],
                        notify      => Service["lm_sensors"],
                        creates     => "/var/local/sensors-detect",
                        refreshonly => true,
                    } # exec

                    service { "lm_sensors":
                        enable  => true,
                        require => Package["lm_sensors"],
                    } # service

                   ganglia::metrics::gmetric { "health/lm_sensors/lm_sensors.sh" :
                   		minute	=> [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
                   } # ganglia metric
                } # default

                # do nothing if its virtual
                kvm: { }

            } # case $productname
        } # physical

        # by default do nothing
        default: { }
   } # case $virtual




}