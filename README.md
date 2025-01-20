# Microsoft 365 License Transition Scripts

This repository contains PowerShell scripts for managing Microsoft 365 license transitions from E3 to E5.

## Test Script (Test-SingleUser.ps1)

This script allows you to test the license transition process on a single user before running it on multiple users. It includes safety checks and verification steps.

### Prerequisites

- PowerShell 5.1 or higher
- MSOnline PowerShell module
- Global Administrator or License Administrator permissions
- Available E5 licenses in your tenant

### Installation

1. Install the MSOnline PowerShell module:
```powershell
Install-Module MSOnline
```

2. Download or clone this repository

### Usage

1. Edit the script to set your test user's email:
```powershell
$testUserEmail = "testuser@yourdomain.com"
```

2. Run the script in PowerShell as Administrator:
```powershell
.\Test-SingleUser.ps1
```

### Safety Features

- Verifies E3 license before starting
- Waits for license propagation
- Verifies E5 license before removing E3
- Includes error handling and logging
- Shows final license status

## License

MIT