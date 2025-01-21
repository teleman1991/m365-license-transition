# Connect to Microsoft 365
Connect-MsolService

# Get available license information first
Write-Host "`nAvailable licenses in tenant:" -ForegroundColor Cyan
Get-MsolAccountSku | Format-Table -AutoSize AccountSkuId, SkuPartNumber, ActiveUnits, ConsumedUnits

# Define test user
$testUserEmail = "amonroe@compassdatacenters.com" # Replace with your test user's email

# Get current user license state
Write-Host "`nCurrent licenses for $testUserEmail:" -ForegroundColor Cyan
try {
    $testUser = Get-MsolUser -UserPrincipalName $testUserEmail
    $testUser.Licenses | Format-Table -Property AccountSkuId, SkuPartNumber
}
catch {
    Write-Host "Error finding test user: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Get tenant name from user license format
$tenantName = ($testUser.Licenses[0].AccountSkuId -split ':')[0]

# Define SKU IDs using tenant prefix
$E3_SKU = "$tenantName`:ENTERPRISEPACK" # E3 License
$E5_SKU = "$tenantName`:ENTERPRISE_PREMIUM" # E5 License

Write-Host "`nUsing the following SKU IDs:" -ForegroundColor Yellow
Write-Host "E3 SKU: $E3_SKU"
Write-Host "E5 SKU: $E5_SKU"

# Verify test user has E3 license
$hasE3 = ($testUser.Licenses).AccountSkuId -contains $E3_SKU
if (-not $hasE3) {
    Write-Host "`nTest user does not have an E3 license! Exiting..." -ForegroundColor Red
    Write-Host "Current licenses:" -ForegroundColor Yellow
    $testUser.Licenses | Format-Table -Property AccountSkuId, SkuPartNumber
    exit
}
Write-Host "`nTest user found with E3 license" -ForegroundColor Green

# Add E5 license to test user
try {
    Write-Host "`nAdding E5 license to $testUserEmail..."
    Set-MsolUserLicense -UserPrincipalName $testUserEmail -AddLicenses $E5_SKU
    Write-Host "Successfully added E5 license" -ForegroundColor Green
}
catch {
    Write-Host "Error adding E5 license: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Wait for license propagation
Write-Host "`nWaiting 30 seconds for license changes to propagate..."
Start-Sleep -Seconds 30

# Verify E5 license was added successfully
$updatedUser = Get-MsolUser -UserPrincipalName $testUserEmail
$hasE5 = ($updatedUser.Licenses).AccountSkuId -contains $E5_SKU

if ($hasE5) {
    Write-Host "`nE5 license verified. Proceeding to remove E3 license..." -ForegroundColor Green
    
    # Remove E3 license
    try {
        Set-MsolUserLicense -UserPrincipalName $testUserEmail -RemoveLicenses $E3_SKU
        Write-Host "Successfully removed E3 license" -ForegroundColor Green
    }
    catch {
        Write-Host "Error removing E3 license: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please remove E3 license manually after verifying E5 functionality" -ForegroundColor Yellow
    }
}
else {
    Write-Host "`nE5 license was not found after waiting! Please check the account manually." -ForegroundColor Red
    exit
}

# Final verification
$finalUser = Get-MsolUser -UserPrincipalName $testUserEmail
Write-Host "`nFinal license status for $($testUserEmail):" -ForegroundColor Cyan
$finalUser.Licenses | Format-Table -Property AccountSkuId, SkuPartNumber

Write-Host "`nTest completed!" -ForegroundColor Green
