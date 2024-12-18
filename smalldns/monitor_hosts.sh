#!/bin/sh

echo "Starting monitor_hosts.sh"
LAST_MODIFIED_TIME=$(date +%s)
COOLDOWN=30  # Cooldown period in seconds
RESTART_SCHEDULED=false  # Flag to track if a restart is already scheduled

restart_dnsmasq() {
  echo "Restarting dnsmasq..."
  killall -HUP dnsmasq  # Sends the HUP signal to dnsmasq to restart it
  LAST_MODIFIED_TIME=$(date +%s)  # Update the last modified time
  RESTART_SCHEDULED=false  # Reset the restart flag
}

while true; do
  echo "Waiting for /etc/hosts modification..."
  inotifywait -e modify /etc/hosts

  CURRENT_TIME=$(date +%s)
  TIME_DIFF=$((CURRENT_TIME - LAST_MODIFIED_TIME))

  echo "Modification detected: $TIME_DIFF seconds since last restart."

  if [ $TIME_DIFF -ge $COOLDOWN ]; then
    # If the cooldown period has passed, restart immediately
    restart_dnsmasq
  elif [ "$RESTART_SCHEDULED" = false ]; then
    # Schedule a restart after the remaining cooldown time
    RESTART_SCHEDULED=true
    REMAINING_COOLDOWN=$((COOLDOWN - TIME_DIFF))
    echo "Scheduling restart in $REMAINING_COOLDOWN seconds..."
    (sleep $REMAINING_COOLDOWN && restart_dnsmasq) &
  else
    echo "Restart already scheduled. Waiting for cooldown."
  fi
done
