# Connect to Microsoft 365
Connect-MsolService

# Define SKU IDs for licenses
$E3_SKU_1 = "6fd2c87f-b296-42f0-b197-1e91e994b900" # Enterprise E3 (older)
$E3_SKU_2 = "05e9a617-0261-4cee-bb44-138d3ef5d965" # Enterprise E3 (newer)
$E5_SKU = "c7df2760-2c81-4ef7-b578-5b5392b571df" # Enterprise E5

# Define test user
$testUserEmail = "testuser@yourdomain.com" # Replace with your test user's email

# Verify test user exists and has E3 license
Write-Host "Checking test user $testUserEmail..."
try {
    $testUser = Get-MsolUser -UserPrincipalName $testUserEmail
    
    # Check for either E3 SKU
    $hasE3 = ($testUser.Licenses).AccountSkuId -match $E3_SKU_1 -or ($testUser.Licenses).AccountSkuId -match $E3_SKU_2
    
    # Debug output
    Write-Host "Current licenses:" -ForegroundColor Yellow
    $testUser.Licenses | Format-Table -Property AccountSkuId
    
    if (-not $hasE3) {
        Write-Host "Test user does not have an E3 license! Exiting..." -ForegroundColor Red
        exit
    }
    Write-Host "Test user found with E3 license" -ForegroundColor Green
}
catch {
    Write-Host "Error finding test user: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Add E5 license to test user
try {
    Write-Host "Adding E5 license to $testUserEmail..."
    Set-MsolUserLicense -UserPrincipalName $testUserEmail -AddLicenses $E5_SKU
    Write-Host "Successfully added E5 license" -ForegroundColor Green
}
catch {
    Write-Host "Error adding E5 license: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Wait for license propagation
Write-Host "Waiting 30 seconds for license changes to propagate..."
Start-Sleep -Seconds 30

# Verify E5 license was added successfully
$updatedUser = Get-MsolUser -UserPrincipalName $testUserEmail
$hasE5 = ($updatedUser.Licenses).AccountSkuId -match $E5_SKU

if ($hasE5) {
    Write-Host "E5 license verified. Proceeding to remove E3 license..." -ForegroundColor Green
    
    # Remove E3 license - try both SKUs
    try {
        if (($updatedUser.Licenses).AccountSkuId -match $E3_SKU_1) {
            Set-MsolUserLicense -UserPrincipalName $testUserEmail -RemoveLicenses $E3_SKU_1
        }
        if (($updatedUser.Licenses).AccountSkuId -match $E3_SKU_2) {
            Set-MsolUserLicense -UserPrincipalName $testUserEmail -RemoveLicenses $E3_SKU_2
        }
        Write-Host "Successfully removed E3 license" -ForegroundColor Green
    }
    catch {
        Write-Host "Error removing E3 license: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please remove E3 license manually after verifying E5 functionality" -ForegroundColor Yellow
    }
}
else {
    Write-Host "E5 license was not found after waiting! Please check the account manually." -ForegroundColor Red
    exit
}

# Final verification
$finalUser = Get-MsolUser -UserPrincipalName $testUserEmail
Write-Host "`nFinal license status for $($testUserEmail):" -ForegroundColor Cyan
$finalUser.Licenses | Format-Table -Property AccountSkuId

Write-Host "Test completed!" -ForegroundColor Green