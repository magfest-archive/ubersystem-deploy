import 'uber_server.pp'
import 'logging_server.pp'
import 'logging_node.pp'

hiera_include('classes')

node default {

}
