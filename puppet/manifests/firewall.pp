class firewall_webserver {
  if defined(Class['ufw']) == false {
    include ufw 

    #ufw::allow { "http":
    #   port => 80
    #}

    #ufw::allow { "https":
    #  port => 443
    #}
  }
}

class firewall_sshserver {
}
