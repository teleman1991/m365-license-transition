# Connect to Microsoft 365
Connect-MsolService

# Define SKU IDs for licenses
$E3_SKU = "6fd2c87f-b296-42f0-b197-1e91e994b900" # Enterprise E3
$E5_SKU = "c7df2760-2c81-4ef7-b578-5b5392b571df" # Enterprise E5

# Get all users with E3 licenses
Write-Host "Getting users with E3 licenses..."
$E3Users = Get-MsolUser -All | Where-Object {($_.Licenses).AccountSkuId -match $E3_SKU}

# Add E5 licenses to users with E3
foreach ($user in $E3Users) {
    try {
        Write-Host "Adding E5 license to $($user.UserPrincipalName)..."
        Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses $E5_SKU
        Write-Host "Successfully added E5 license to $($user.UserPrincipalName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error adding E5 license to $($user.UserPrincipalName): $($_.Exception.Message)" -ForegroundColor Red
    }
}