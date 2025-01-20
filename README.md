# Microsoft 365 License Transition Scripts

This repository contains PowerShell scripts for managing Microsoft 365 license transitions from E3 to E5.

## Main Script (License-Transition.ps1)

This script handles the bulk transition of users from E3 to E5 licenses. It includes progress tracking, error handling, and a detailed summary of the operations performed.

### Features
- Automatically identifies all users with E3 licenses
- Adds E5 licenses to eligible users
- Removes E3 licenses after successful E5 assignment
- Progress tracking with percentage completion
- Detailed error handling and logging
- Summary report of successful and failed operations
- Waiting period for license propagation

### Usage
```powershell
.\License-Transition.ps1
```

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

1. For testing on a single user, edit Test-SingleUser.ps1:
```powershell
$testUserEmail = "testuser@yourdomain.com"
```

2. Run the appropriate script in PowerShell as Administrator:
```powershell
# For testing with a single user:
.\Test-SingleUser.ps1

# For transitioning all eligible users:
.\License-Transition.ps1
```

### Safety Features

- Verifies licenses before making changes
- Waits for license propagation
- Includes error handling and logging
- Shows detailed progress and status
- Provides summary reports

## License

MIT