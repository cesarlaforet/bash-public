#!/bin/bash

# Cloudflare API details
CLOUDFLARE_API_URL="https://api.cloudflare.com/client/v4"
CLOUDFLARE_EMAIL="your_email@example.com"                   # CF email login
CLOUDFLARE_API_TOKEN="your_api_token"                       # Generated API KEY for DNS access
CLOUDFLARE_API_KEY="your_api_key"                           # GLOBAL API KEY
CLOUDFLARE_ZONE_ID="your_zone_id"                           # DNS zone identifier

# Main domain to compare to public ip
MAIN_DOMAIN="main-example.com"

# List of DNS records to update, use full domain
DNS_RECORDS=(
    "example.com:<record_type>"  # Replace with your domain and record type
    # Add more DNS records as needed
)

get_public_ip() {
    local ip
    ip=$(dig +short txt ch whoami.cloudflare @1.0.0.1)
    echo "$ip"
}

get_cloudflare_ip() {
    local ip
    ip=$(dig +short $MAIN_DOMAIN)
    echo "$ip"
}

update_dns_records() {
    local new_ip="$1"

    for record in "${DNS_RECORDS[@]}"; do
        IFS=: read -r record_name record_type <<< "$record"

        # Get existing DNS record
        url="$CLOUDFLARE_API_URL/zones/$CLOUDFLARE_ZONE_ID/dns_records?type=$record_type&name=$record_name"
        echo "$url"
        response=$(curl -sS -X GET "$url" -H "Content-Type:application/json" -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN")

        if [[ -n "$response" ]]; then
            dns_record=$(echo "$response" | jq -r '.result[0]')
echo $dns_record
            current_ip=$(echo "$dns_record" | jq -r '.content')
echo $current_ip

            if [[ "$current_ip" != "$new_ip" ]]; then
                # Update DNS record with new IP
                update_data="{\"type\":\"$record_type\",\"name\":\"$record_name\",\"content\":$new_ip}"
                update_url="$CLOUDFLARE_API_URL/zones/$CLOUDFLARE_ZONE_ID/dns_records/$(echo "$dns_record" | jq -r '.id')"
echo $update_url
echo $update_data
                update_response=$(curl -sS -X PUT "$update_url"  -H "Content-Type:application/json" -H "X-Auth-Email: $CLOUDFLARE_EMAIL" -H "X-Auth-Key: $CLOUDFLARE_API_KEY" --data "$update_data")

                if [[ $(echo "$update_response" | jq -r '.success') == "true" ]]; then
                    echo "Updated DNS record for $record_name to $new_ip"
                else
                    echo "Failed to update DNS record for $record_name: $update_response"
                fi
            else
                echo "DNS record for $record_name is up to date"
            fi
        else
            echo "Failed to fetch DNS record for $record_name: $response"
        fi
    done
}

public_ip=$(get_public_ip)
if [[ -n "$public_ip" ]]; then
    cloudflare_ip=$(get_cloudflare_ip)
    if [[ -n "$cloudflare_ip" ]]; then
        if [[ "$public_ip" != "$cloudflare_ip" ]]; then
            update_dns_records "$public_ip"
        else
            echo "DNS record for $DNS_RECORD is up to date: $public_ip"
        fi
    else
        echo "Failed to obtain Cloudflare DNS record"
    fi
else
    echo "Failed to obtain public IP address for unlockingtech.com"
fi
