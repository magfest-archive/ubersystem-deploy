class uber-firewall {
  include ufw

  ufw::allow { "allow-ssh-from-all":
      port => 22,
  }

  ufw::allow { "http":
    port => 80
  }

  ufw::allow { "https":
    port => 443
  }

  # (the IP is blocked if it initiates 6 or more connections within 30 seconds):
  ufw::limit { 22: }
}
