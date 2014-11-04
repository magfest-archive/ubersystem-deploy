import 'uber_server.pp'
import 'logging_server.pp'
import 'logging_node.pp'
import 'ssl.pp'

hiera_include('classes')

node default {

}
