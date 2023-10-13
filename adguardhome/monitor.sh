#!/bin/bash

#sudo chmod u+x monitor.sh

remove_old_rules() {
    # Get the list of rich rules in the public zone
    output=$(sudo firewall-cmd --permanent --zone=public --list-rich-rules)
	
    # Process the output to find and separate rule-family pairs
    pairs=()
    current_pair=""
    for word in $output; do
        if [ "$word" == "rule" ]; then
            if [ -n "$current_pair" ]; then
                pairs+=("$current_pair")
            fi
            current_pair="$word"
        else
            current_pair="$current_pair $word"
        fi
    done

    # Check if there is an unfinished pair and add it
    if [ -n "$current_pair" ]; then
        pairs+=("$current_pair")
    fi

    # Loop through and remove each rule
    for pair in "${pairs[@]}"; do
        sudo firewall-cmd --permanent --zone=public --remove-rich-rule="$pair"
    done
}

add_new_rules() {
	local configfile="$1"
	disallowed_clients=$(python3 -c "import yaml; data = yaml.safe_load(open('$configfile')); print(data.get('dns', {}).get('disallowed_clients', []))")

	# Remove the first character '[' and the last character ']'
	disallowed_clients=${disallowed_clients#\[}
	disallowed_clients=${disallowed_clients%\]}

	# Convert the disallowed clients string to an array
	IFS=', ' read -ra disallowed_clients <<< "$disallowed_clients"


	for ip in "${disallowed_clients[@]}"; do
		sudo firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address=$ip service name='dns' drop"
	done
}

# Function to reload the firewall
reload_firewall() {
    sudo firewall-cmd --reload
}



# Path to the config.yaml file
config_file="/AdGuardData/confdir/AdGuardHome.yaml"


while true; do
    disallowed_clients=$(python3 -c "import yaml; data = yaml.safe_load(open('$config_file')); print(data.get('dns', {}).get('disallowed_clients', []))")

    # Initial MD5 checksum of the config.yaml file
    initial_checksum=$(echo -n "$disallowed_clients" | md5sum | awk '{print $1}')

    # Use inotifywait to monitor changes in the config.yaml file
    inotifywait -e modify "$config_file"

    disallowed_clients=$(python3 -c "import yaml; data = yaml.safe_load(open('$config_file')); print(data.get('dns', {}).get('disallowed_clients', []))")
    # Calculate the new MD5 checksum
    new_checksum=$(echo -n "$disallowed_clients" | md5sum | awk '{print $1}')

    # Compare the new and initial checksums
    if [ "$new_checksum" != "$initial_checksum" ]; then
        echo "config.yaml has changed."
        remove_old_rules
		add_new_rules "$config_file"
		reload_firewall
    fi
done
