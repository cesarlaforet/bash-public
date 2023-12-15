# Dynamic DNS Update Script for Cloudflare

This Bash script allows you to automatically update DNS records in Cloudflare based on your current public IP address. It is useful for maintaining DNS records for domains that have dynamic IP addresses.

## Prerequisites

Before using this script, make sure you have the following prerequisites:

- Cloudflare account with API access.
- Cloudflare API Token or Global API Key (recommended to use the API Token for better security).
- Domain(s) hosted on Cloudflare.
- `dig` command-line tool installed on your system.
- `jq` command-line tool installed on your system (for parsing JSON responses).

## Configuration

1. Make the script executable by running the following command in your terminal:

   ```bash
   chmod +x update_dns.sh

1. Edit the script (`update_dns.sh`) and set the following variables:

   - `CLOUDFLARE_EMAIL`: Your Cloudflare email address.
   - `CLOUDFLARE_API_TOKEN`: Your Cloudflare API Token.
   - `CLOUDFLARE_API_KEY`: Your Cloudflare Global API Key (optional if using API Token with required permissions).
   - `CLOUDFLARE_ZONE_ID`: Your Cloudflare DNS zone identifier.
   - `MAIN_DOMAIN`: The main domain name that your script will compare the public IP against.
   - `DNS_RECORDS`: An array of DNS records to update in the format: `"example.com:<record_type>"`. Add more records as needed.

2. Ensure that the script (`update_dns.sh`) is executable:

   ```bash
   chmod +x update_dns.sh

## Usage

1. To run the script and update your DNS records in Cloudflare, simply execute the script:

    ```bash
    ./update_dns.sh

The script will compare your current public IP address (retrieved using dig and Cloudflare's 'whoami' endpoint) with the IP address associated with the MAIN_DOMAIN. If they differ, it will update the specified DNS records in Cloudflare.

## Scheduling Updates

1. You can schedule the script to run automatically at regular intervals using a cron job. For example, to run the script every 10 minutes, add the following line to your crontab:

    ```cron
    */10 * * * * /path/to/update_dns.sh

Make sure to replace /path/to/update_dns.sh with the actual path to your script.

## License

This script is provided under the MIT License. See the LICENSE file for more details.


`@2023-12-15`
