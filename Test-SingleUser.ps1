# Install and import Microsoft Graph modules if not already installed
If (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Install-Module Microsoft.Graph.Users -Force
}
If (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Identity.DirectoryManagement)) {
    Install-Module Microsoft.Graph.Identity.DirectoryManagement -Force
}

# Import required modules
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

# Define SKU IDs
$E3_SKU = "compassdatacenter:SPE_E3"
$E5_SKU = "compassdatacenter:Microsoft_365_E5_(no_Teams)"

# Define test user
$testUserEmail = "amadmin@compassdatacenters.com" # Replace with your test user's email

# Get current user license state
Write-Host "`nCurrent licenses for $($testUserEmail):" -ForegroundColor Cyan
try {
    $testUser = Get-MgUser -UserId $testUserEmail -Property AssignedLicenses
    $testUserLicenses = Get-MgUserLicenseDetail -UserId $testUserEmail
    $testUserLicenses | Format-Table -Property SkuId, SkuPartNumber
}
catch {
    Write-Host "Error finding test user: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Verify test user has E3 license
$hasE3 = $testUserLicenses.AccountSkuId -contains $E3_SKU
if (-not $hasE3) {
    Write-Host "`nTest user does not have an E3 license! Exiting..." -ForegroundColor Red
    Write-Host "Current licenses:" -ForegroundColor Yellow
    $testUserLicenses | Format-Table -Property SkuId, SkuPartNumber
    exit
}
Write-Host "`nTest user found with E3 license" -ForegroundColor Green

# Add E5 license to test user
try {
    Write-Host "`nAdding E5 license to $($testUserEmail)..."
    $params = @{
        addLicenses = @(
            @{
                skuId = $E5_SKU
            }
        )
        removeLicenses = @()
    }
    Set-MgUserLicense -UserId $testUserEmail -BodyParameter $params
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
$updatedUserLicenses = Get-MgUserLicenseDetail -UserId $testUserEmail
$hasE5 = $updatedUserLicenses.AccountSkuId -contains $E5_SKU

if ($hasE5) {
    Write-Host "`nE5 license verified. Proceeding to remove E3 license..." -ForegroundColor Green
    
    # Remove E3 license
    try {
        $params = @{
            addLicenses = @()
            removeLicenses = @(
                $E3_SKU
            )
        }
        Set-MgUserLicense -UserId $testUserEmail -BodyParameter $params
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
$finalUserLicenses = Get-MgUserLicenseDetail -UserId $testUserEmail
Write-Host "`nFinal license status for $($testUserEmail):" -ForegroundColor Cyan
$finalUserLicenses | Format-Table -Property SkuId, SkuPartNumber

Write-Host "`nTest completed!" -ForegroundColor Green

# Disconnect from Microsoft Graph
Disconnect-MgGraph
