class ganglia::metrics::smart {

	include ganglia::metrics
	
    case $virtual {
        physical: {
            case $productname {
                # systems that do not use KVM have productname blank
                default: {
                    
                   ganglia::metrics::gmetric { "health/smartctl/smartctl.sh" :
                   		minute	=> '*'
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