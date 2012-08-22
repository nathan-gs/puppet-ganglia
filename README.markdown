# Puppet: Ganglia

## Usage

### Using unicast (not the Ganglia default way)

#### on the nodes

    include ganglia::gmon

    # one or more cluster heads:
    ganglia::gmon::unicast_send { 'master':
        host    => 'master-for-this-cluster',
    }

    # define the name of the cluster (& owner)
    ganglia::gmon::cluster { 'cluster':
        owner   => 'DataCrunchers',
    }

#### On the head node

The node instructions apply to the head node as well.

    # accept tcp connections (for communication between gmon & gmetad).
    ganglia::gmon::tcp_accept { 'localhost' :
        bind    => 'localhost',
    }

    ganglia::gmon::unicast_receive { 'cluster': }

    include ganglia::gmeta

    ganglia::gmeta::retriever { 'cluster':
        hosts   => { 'master-for-this-cluster' => 8649 }
    }


## Author

[Nathan Bijnens <nathan@nathan.gs>](nathan.gs)