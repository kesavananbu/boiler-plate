Prerequesites :
  pip install pyyaml
  apt-get install inotify-tools

Note: Change the config_file path in the monitor.sh and execute the sudo chmod u+x monitor.sh

Start Service:
  sudo systemctl daemon-reload
  sudo systemctl enable firewallblocker.service
  sudo systemctl start firewallblocker.service

So whenever you add/update the ip or iplist in the disallowist client ips in the AdguardHome -> Settings -> DNS Settings [Disallowed clients] automatically updates the ip blocklist in the firewall-cmd
