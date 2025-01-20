# Connect to Microsoft 365
Connect-MsolService

# Define SKU IDs for licenses
$E3_SKU = "6fd2c87f-b296-42f0-b197-1e91e994b900" # Enterprise E3
$E5_SKU = "c7df2760-2c81-4ef7-b578-5b5392b571df" # Enterprise E5

# Define test user
$testUserEmail = "testuser@yourdomain.com" # Replace with your test user's email

# Verify test user exists and has E3 license
Write-Host "Checking test user $testUserEmail..."
try {
    $testUser = Get-MsolUser -UserPrincipalName $testUserEmail
    $hasE3 = ($testUser.Licenses).AccountSkuId -match $E3_SKU
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