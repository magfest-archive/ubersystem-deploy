class firewall_webserver {
  include ufw 

  ufw::allow { "http":
    port => 80
  }

  ufw::allow { "https":
    port => 443
  }
}

class firewall_sshserver {
}
