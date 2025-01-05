#!/bin/bash

# Function to check if a command exists and install it if it doesn't
check_and_install() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 could not be found, installing..."
        sudo dnf install -y $1
    else
        echo "$1 is already installed"
    fi
}

# Check if .env file exists and create sample if it doesn't
if [ ! -f .env ]; then
    echo "Creating sample .env file..."
    cat <<EOF >.env
# .env file for backup.sh
SERVER_URL=
SHARE_NAME=
USERNAME=
PASSWORD=
SHARE_SUB_FOLDER=
EOF
    echo "Sample .env file created, please fill in the required values"
    exit 1
    return 1
else
    # Because file exists verify if the values are filled in
    if grep -q "SERVER_URL=" .env && [ -n "$(grep 'SERVER_URL=' .env | cut -d '=' -f2)" ]; then
        echo "SERVER_URL is set"
    else
        echo "SERVER_URL is not set"
    fi
    
    if grep -q "SHARE_NAME=" .env && [ -n "$(grep 'SHARE_NAME=' .env | cut -d '=' -f2)" ]; then
        echo "SHARE_NAME is set"
    else
        echo "SHARE_NAME is not set"
    fi
    
    if grep -q "USERNAME=" .env && [ -n "$(grep 'USERNAME=' .env | cut -d '=' -f2)" ]; then
        echo "USERNAME is set"
    else
        echo "USERNAME is not set"
    fi
    
    if grep -q "PASSWORD=" .env && [ -n "$(grep 'PASSWORD=' .env | cut -d '=' -f2)" ]; then
        echo "PASSWORD is set"
    else
        echo "PASSWORD is not set"
    fi
    
    if grep -q "SHARE_SUB_FOLDER=" .env && [ -n "$(grep 'SHARE_SUB_FOLDER=' .env | cut -d '=' -f2)" ]; then
        echo "SHARE_SUB_FOLDER is set"
    else
        echo "SHARE_SUB_FOLDER is not set"
    fi

    # Warn the user that all values must be filled in and break the script
    if [ -z "$(grep 'SERVER_URL=' .env | cut -d '=' -f2)" ] || \
       [ -z "$(grep 'SHARE_NAME=' .env | cut -d '=' -f2)" ] || \
       [ -z "$(grep 'USERNAME=' .env | cut -d '=' -f2)" ] || \
       [ -z "$(grep 'PASSWORD=' .env | cut -d '=' -f2)" ] || \
       [ -z "$(grep 'SHARE_SUB_FOLDER=' .env | cut -d '=' -f2)" ]; then
        echo "Please fill in all the required values in the .env file"
        exit 1
        return 1
    fi
fi

# Load the environment variables
source .env

# Check and install zip and smbclient if necessary
check_and_install zip
check_and_install samba-client

# Get the hostname
hostname=$(hostname)

# Get the current date and time
datetime=$(date '+%Y-%m-%d_%H-%M-%S')

# Create the zip file name
zip_filename="${hostname}_${datetime}.zip"

# Create the zip file with the contents of the current folder including subfolders and files, excluding specific folders
zip -r "$zip_filename" . -x ".*/*"

# Verify the network path
network_path="//$SERVER_URL/$SHARE_NAME"
echo "Network path: $network_path"

if smbclient -L $SERVER_URL -U $USERNAME%$PASSWORD | grep -q "$SHARE_NAME"; then
    # Upload the zip file to the samba share
    if smbclient "$network_path" -U $USERNAME%$PASSWORD -c "cd $SHARE_SUB_FOLDER/$hostname; put $zip_filename"; then
        # Clean up the zip file
        rm "$zip_filename"
        
        # Keep only the 10 most recent backups
        echo "Files to be deleted:"
        smbclient "$network_path" -U $USERNAME%$PASSWORD -c "cd $SHARE_SUB_FOLDER/$hostname; ls" | awk '$1 ~ /\.zip$/ {print $1}' | sort -r | awk 'NR>10 {print $1}'

        # Deleting files
        smbclient "$network_path" -U $USERNAME%$PASSWORD -c "cd $SHARE_SUB_FOLDER/$hostname; ls" | awk '$1 ~ /\.zip$/ {print $1}' | sort -r | awk 'NR>10 {print $1}' | while read -r file; do
            echo "Deleting file: $file"
            smbclient "$network_path" -U $USERNAME%$PASSWORD -c "cd $SHARE_SUB_FOLDER/$hostname; rm $file"
        done
        
        # Print a success message
        echo "Backup completed and uploaded to the samba share"
    else
        # Print an error message
        echo "Failed to upload the backup to the samba share"
        exit 1
        return 1
    fi
else
    echo "Network path $network_path is not available"
    exit 1
    return 1
fi

# Add a cron job to run this script every day between 1am and 6am
cron_job="0 1-6 * * * /bin/bash $(realpath $0)"
(crontab -l 2>/dev/null | grep -v -F "$cron_job"; echo "$cron_job") | crontab -