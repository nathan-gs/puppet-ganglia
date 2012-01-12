class ganglia::metrics::smart {

	include ganglia::metrics
	
    case $virtual {
        physical: {
            case $productname {
                # systems that do not use KVM have productname blank
                default: {
                    
                   ganglia::metrics::gmetric { "health/smartctl/smartctl.sh" :
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