Prerequesites :
  pip install pyyaml
  apt-get install inotify-tools

Note: Change the config_file path in the monitor.sh and execute the sudo chmod u+x monitor.sh

Start Service:
  sudo systemctl daemon-reload
  sudo systemctl enable firewallblocker.service
  sudo systemctl start firewallblocker.service

