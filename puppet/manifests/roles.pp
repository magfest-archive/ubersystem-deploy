class roles {

}

class roles::uber_server () inherits roles {
  include uber
  include uber::rams_app_stack
}