Prerequesites :

# Macvlan create if you are using other than bridge mode
docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 --ipv6 --subnet=fe80::/64 --gateway=fe80::1 -o parent=eth0 docker_vlan

# Bridge Mode or host mode

  pip install pyyaml
  apt-get install inotify-tools

Note: Change the config_file path in the monitor.sh and execute the sudo chmod u+x monitor.sh

Start Service:
  sudo systemctl daemon-reload
  sudo systemctl enable firewallblocker.service
  sudo systemctl start firewallblocker.service

So whenever you add/update the ip or iplist in the disallowist client ips in the AdguardHome -> Settings -> DNS Settings [Disallowed clients] automatically updates the ip blocklist in the firewall-cmd


