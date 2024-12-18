#!/bin/sh

echo "Starting monitor_hosts.sh"
LAST_MODIFIED_TIME=$(date +%s)
PENDING_RESTART=false
COOLDOWN=30  # Seconds

restart_dnsmasq() {
  echo "restarting dnsmasq..."
  PENDING_RESTART=false  # Reset the pending restart flag
  killall -HUP dnsmasq  # Sends the HUP signal to dnsmasq to restart it
  LAST_MODIFIED_TIME=$(date +%s)  # Update the last modified time  
}

while true; do
  echo "Waiting for /etc/hosts modification..."
  inotifywait -e modify /etc/hosts

  CURRENT_TIME=$(date +%s)
  TIME_DIFF=$((CURRENT_TIME - LAST_MODIFIED_TIME))

  echo "Modification detected: $TIME_DIFF seconds since last change."

    # Mark the restart as pending if within cooldown window
  if [ $TIME_DIFF -lt $COOLDOWN ] && [ "$PENDING_RESTART" = false ]; then
    echo "/etc/hosts modified, marking restart as pending."
    PENDING_RESTART=true
  fi
  
    # Restart dnsmasq after the cooldown period if it's pending
  if [ $TIME_DIFF -ge $COOLDOWN ] && [ "$PENDING_RESTART" = true ]; then
    echo "restarting the service crossed colling period"
    restart_dnsmasq  # Restart the service
  fi
  
    # If changes happen again within the cooldown window, set a background task to restart after 30 seconds
  if [ "$PENDING_RESTART" = true ]; then
    echo "restarting the service once crossed colling period"
    # Set a background process to restart dnsmasq after the remaining time
    (sleep $((COOLDOWN - TIME_DIFF)) && restart_dnsmasq) &
  fi
done
