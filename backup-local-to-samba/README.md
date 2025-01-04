# Backup Script

This script is designed to create a backup of your files and directories, excluding hidden directories, and store them in a specified network location.

## Prerequisites

- `zip` and `smbclient` must be installed on your system. The script will check for these and install them if they are not found.
- A `.env` file must be present in the same directory as the script, containing the necessary configuration variables.

## Configuration

Create a `.env` file in the same directory as the script with the following content:

```env
# .env file for backup.sh
SERVER_URL=your_server_url
SHARE_NAME=your_share_name
USERNAME=your_username
PASSWORD=your_password
SHARE_SUB_FOLDER=your_share_sub_folder
```

Replace the placeholder values with your actual configuration.

## Usage

Ensure the script is executable:

```bash
chmod +x backup.sh
```

Run the script:

```bash
./backup.sh
```

## Script Details

- The script checks if the necessary commands (`zip` and `smbclient`) are installed and installs them if they are not found.
- It verifies the presence of the `.env` file and creates a sample file if it does not exist.
- It checks if all required values in the `.env` file are filled in.
- It creates a zip file of the current directory, excluding hidden directories.
- It uploads the zip file to the specified network location using `smbclient`.

## Notes

- Ensure that the `.env` file does not contain any hidden characters or spaces.
- The script will exit if any required values in the `.env` file are missing.

## License

This project is licensed under the MIT License.