# Connect to Microsoft 365
Connect-MsolService

# Get and display license information
Write-Host "Getting available license information..." -ForegroundColor Yellow
Get-MsolAccountSku | Format-Table -AutoSize AccountSkuId, SkuPartNumber, ActiveUnits, ConsumedUnits

# Get detailed user license info for a test user
$testUserEmail = "testuser@yourdomain.com" # Replace with your test user's email
Write-Host "`nGetting license information for $testUserEmail..." -ForegroundColor Yellow

try {
    $user = Get-MsolUser -UserPrincipalName $testUserEmail
    Write-Host "`nLicenses assigned to $($user.UserPrincipalName):" -ForegroundColor Green
    $user.Licenses | Format-Table -Property AccountSkuId, SkuPartNumber

    Write-Host "`nDetailed license information:" -ForegroundColor Green
    foreach ($license in $user.Licenses) {
        Write-Host "`nLicense: $($license.AccountSkuId)" -ForegroundColor Cyan
        $license.ServiceStatus | Format-Table -AutoSize ServicePlan, ProvisioningStatus
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}