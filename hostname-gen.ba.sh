#!/bin/bash

# List of common brands to expect
brands="apple microsoft dell qnap pi"

# Initialize a variable to store the found brand defaulted to node
found_brand="node"

# Loop through the brand names and check if they appear in the system information or naming
for brand in $brands; do
    if [[ $(hostnamectl | grep -i "$brand") ]]; then
        found_brand=$brand
        break
    fi
done

# Use the 'ip' command to get the MAC address of the primary Ethernet interface (eth0)
# Adjust 'eth0' if your primary network interface has a different name
mac_address=$(ip link show eth0 | awk '/ether/ {print $2}')

# Remove colons from the MAC address
mac_address_simple=$(echo "$mac_address" | tr -d ':')

# Extract the last 6 characters of the MAC address
mac_address_last6="${mac_address_simple: -6}"

# If a MAC address and a brand were found, process them
if [[ -n "$mac_address_last6" && -n "$found_brand" ]]; then
    # Create a hostname by appending the brand and last 6 characters of MAC address
    hostname="${found_brand}-${mac_address_last6}"

    # Write the hostname to /etc/hostname
    echo "$hostname" > /etc/hostname

    # Format and update /etc/hosts
    echo "127.0.0.1   $hostname.localdomain $hostname localhost.localdomain localhost" > /etc/hosts
    echo "::1         localhost localhost.localdomain" >> /etc/hosts

    echo "Hostname set to $hostname"
else
    echo "Required information could not be found."
fi
