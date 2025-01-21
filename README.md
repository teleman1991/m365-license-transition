# Microsoft 365 License Transition Scripts

This repository contains PowerShell scripts for managing Microsoft 365 license transitions from E3 to E5 using the Microsoft Graph PowerShell SDK.

## Main Script (License-Transition.ps1)

This script handles the bulk transition of users from E3 to E5 licenses. It includes progress tracking, error handling, and a detailed summary of all operations.

### Features
- Uses Microsoft Graph PowerShell SDK for modern authentication
- Automatically identifies all users with E3 licenses
- Adds E5 licenses to eligible users
- Removes E3 licenses after successful E5 assignment
- Progress tracking with percentage completion
- Detailed error handling and logging
- Verification of license assignments
- Summary report of successful and failed operations
- Waiting period for license propagation

### Prerequisites
- PowerShell 5.1 or higher
- Microsoft.Graph.Users module
- Microsoft.Graph.Identity.DirectoryManagement module
- Global Administrator or License Administrator permissions
- Available E5 licenses in your tenant

### Installation
1. Install required Microsoft Graph PowerShell modules:
```powershell
Install-Module Microsoft.Graph.Users
Install-Module Microsoft.Graph.Identity.DirectoryManagement
```

2. Download or clone this repository

## Test Script (Test-SingleUser.ps1)

This script allows you to test the license transition process on a single user before running it on multiple users.

### Usage
1. For testing on a single user, edit Test-SingleUser.ps1:
```powershell
$testUserEmail = "user@yourdomain.com"
```

2. Run the appropriate script in PowerShell as Administrator:
```powershell
# For testing with a single user:
.\Test-SingleUser.ps1

# For transitioning all eligible users:
.\License-Transition.ps1
```

### Safety Features
- Verifies current licenses before making changes
- Waits for license propagation
- Verifies successful E5 assignment before removing E3
- Includes error handling and logging
- Shows detailed progress and status
- Provides summary reports

## Authentication

Both scripts use modern authentication through Microsoft Graph. When you run either script:
1. A browser window will open for authentication
2. Sign in with an account that has appropriate license management permissions
3. Grant consent for the requested permissions if prompted

## SKU IDs

The scripts use the following SKU IDs for license management:
- E3 License: "05e9a617-0261-4cee-bb44-138d3ef5d965" (SPE_E3)
- E5 License: "18a4bd3f-0b5b-4887-b04f-61dd0ee15f5e" (Microsoft_365_E5_(no_Teams))

## Error Handling

The scripts include comprehensive error handling:
- Verification of module installation
- Check for required permissions
- License assignment verification
- Detailed error messages for troubleshooting
- Status updates during execution

## License

MIT