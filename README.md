# DNS Changer Script

This repository contains a script to change the DNS settings on a Windows machine. The script provides an interactive menu to set DNS to various popular providers or disable custom DNS settings and revert to DHCP. It requires administrative privileges to run.

## Usage

1. **Run the Script with Administrator Privileges:**
   - The script checks for administrative privileges and requests them if necessary.

2. **Main Menu:**
   - Choose from the following options:
     - `1`: Set DNS to Custom (Choose Provider)
     - `2`: Disable Custom DNS (Revert to DHCP, Flush DNS, Reset Network)

3. **Set DNS to Custom:**
   - Choose your preferred DNS provider from the following options:
     - `1`: Cloudflare (1.1.1.1, 1.0.0.1)
     - `2`: Google Public DNS (8.8.8.8, 8.8.4.4)
     - `3`: Quad9 (9.9.9.9, 149.112.112.112)
     - `4`: OpenDNS (208.67.222.222, 208.67.220.220)
   - Select the network adapter to apply the DNS settings.
   - The script sets the primary and secondary DNS for the chosen adapter.

4. **Disable Custom DNS:**
   - Revert DNS settings to DHCP.
   - Flush the DNS resolver cache.
   - Reset the network settings, including Winsock catalog and TCP/IP stack.

## Script Instructions

### Check for Administrator Privileges

The script starts by checking if it is running with administrator privileges. If not, it requests the necessary permissions.

### Main Menu

Displays the main menu options to choose between setting a custom DNS or disabling custom DNS.

### Set DNS to Custom

Prompts the user to choose a DNS provider and sets the DNS for the selected network adapter.

### Disable Custom DNS

Reverts the DNS settings to use DHCP, flushes the DNS cache, and resets network settings.
