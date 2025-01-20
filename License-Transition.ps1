# Connect to Microsoft 365
Connect-MsolService

# Define SKU IDs for licenses
$E3_SKU = "05e9a617-0261-4cee-bb44-138d3ef5d965" # Enterprise E3
$E5_SKU = "18a4bd3f-0b5b-4887-b04f-61dd0ee15f5e" # Enterprise E5

# Get all users with E3 licenses
Write-Host "Getting users with E3 licenses..."
$E3Users = Get-MsolUser -All | Where-Object {($_.Licenses).AccountSkuId -match $E3_SKU}

# Initialize counters
$totalUsers = $E3Users.Count
$processedUsers = 0
$successfulE5Adds = 0
$failedE5Adds = 0
$successfulE3Removals = 0
$failedE3Removals = 0

# Add E5 licenses to users with E3
foreach ($user in $E3Users) {
    $processedUsers++
    $percentComplete = [math]::Round(($processedUsers / $totalUsers) * 100, 2)
    
    Write-Host "`nProcessing user $processedUsers of $totalUsers ($percentComplete%)"
    try {
        Write-Host "Adding E5 license to $($user.UserPrincipalName)..."
        Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses $E5_SKU
        Write-Host "Successfully added E5 license to $($user.UserPrincipalName)" -ForegroundColor Green
        $successfulE5Adds++
    }
    catch {
        Write-Host "Error adding E5 license to $($user.UserPrincipalName): $($_.Exception.Message)" -ForegroundColor Red
        $failedE5Adds++
        continue
    }
}

# Wait for license propagation
Write-Host "`nWaiting 30 seconds for license changes to propagate..."
Start-Sleep -Seconds 30

# Get all users with both E3 and E5 licenses
Write-Host "Getting users with both E3 and E5 licenses..."
$DualLicensedUsers = Get-MsolUser -All | Where-Object {
    ($_.Licenses).AccountSkuId -match $E3_SKU -and ($_.Licenses).AccountSkuId -match $E5_SKU
}

# Remove E3 licenses from users who now have E5
foreach ($user in $DualLicensedUsers) {
    try {
        Write-Host "Removing E3 license from $($user.UserPrincipalName)..."
        Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses $E3_SKU
        Write-Host "Successfully removed E3 license from $($user.UserPrincipalName)" -ForegroundColor Green
        $successfulE3Removals++
    }
    catch {
        Write-Host "Error removing E3 license from $($user.UserPrincipalName): $($_.Exception.Message)" -ForegroundColor Red
        $failedE3Removals++
    }
}

# Print summary
Write-Host "`n=== License Transition Summary ===" -ForegroundColor Cyan
Write-Host "Total users processed: $totalUsers"
Write-Host "Successful E5 additions: $successfulE5Adds"
Write-Host "Failed E5 additions: $failedE5Adds"
Write-Host "Successful E3 removals: $successfulE3Removals"
Write-Host "Failed E3 removals: $failedE3Removals"
Write-Host "=================================" -ForegroundColor Cyan

Write-Host "`nLicense transition completed!" -ForegroundColor Green
