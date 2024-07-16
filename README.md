# Network Configuration Scripts
This repository contains two scripts for configuring network settings on a Linux system. The first script (`manual_configure_network.sh`) prompts the user for detailed network settings, and the second script (`auto_configure_network.sh`) takes a single network address in CIDR notation and calculates the necessary settings automatically.
## Installation
```bash
git clone https://github.com/isubroto/FilesImp.git && cd FilesImp

```
## Scripts
### Manual Network Configuration Script
This script prompts the user to input various network settings manually and then configures the network interface accordingly.
#### Usage
```bash
chmod +x manual_configure_network.sh
```
```bash
sudo ./manual_configure_network.sh
```

### Automatic Network Configuration Script
This script takes a single network address in CIDR notation and calculates the subnet mask, broadcast address, and default gateway automatically. It then configures the network interface based on these calculations.

#### Usage

```bash
chmod +x auto_configure_network.sh
```
```bash
sudo ./auto_configure_network.sh
```
## License
This project is licensed under the MIT License - see the LICENSE file for details.
