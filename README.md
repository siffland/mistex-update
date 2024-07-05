# MiSTeX Core Updater

## Description

This bash script automates the process of updating MiSTeX cores for different platforms. It uses sparse checkout to efficiently download only the necessary files for the selected platform, reducing bandwidth usage and storage requirements.

## Features

- Supports multiple platforms (A100T, A200T484, A200T676, K325T)
- Efficiently updates cores using Git sparse checkout
- Remembers the last used platform
- Allows manual platform selection
- Provides a cleanup option to remove the Git directory

## Requirements

- Bash shell
- Git

## Installation

1. Clone this repository or download the `mistex_updater.bash` script.
2. Make the script executable:
chmod +x mistex_updater.bash
Copy3. Place the script in the `/media/fat/Scripts/` directory of your MiSTeX device.

## Usage

Run the script with one of the following options:
./mistex_updater.bash [OPTION]
Copy
### Options:

- `-h, --help`: Show the help message and exit
- `-a, --ask`: Force platform selection prompt
- `-p PLATFORM`: Specify platform (A100T, A200T484, A200T676, K325T)
- `-c, --cleanup`: Remove the Git directory and exit

If no option is provided, the script will use the stored platform or prompt for selection if no platform is stored.

## Examples

1. Update cores using the stored platform:
./mistex_updater.bash
Copy
2. Force platform selection:
./mistex_updater.bash -a
Copy
3. Specify a platform:
./mistex_updater.bash -p A100T
Copy
4. Clean up the Git directory:
./mistex_updater.bash -c
Copy
## Directory Structure

The script manages cores in the following directories:

- `/media/fat/_Arcade/`
- `/media/fat/_Console/`
- `/media/fat/_Utility/`
- `/media/fat/_Computer/`
- `/media/fat/_Other/`

## Configuration

The script stores the selected platform in `/media/fat/mistex_platform.ini`.

## Contribution

Contributions to improve the script are welcome. Please submit a pull request or open an issue on GitHub.

## License

[Specify your license here, e.g., MIT, GPL, etc.]

## Disclaimer

This script is provided as-is, without any warranty. Use at your own risk.
