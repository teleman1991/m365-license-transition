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

# Define SKU IDs (using exact IDs from tenant)
$E3_SKU = "05e9a617-0261-4cee-bb44-138d3ef5d965"  # SPE_E3
$E5_SKU = "18a4bd3f-0b5b-4887-b04f-61dd0ee15f5e"  # Microsoft_365_E5_(no_Teams)

# Define test user
$testUserEmail = "amonroe@compassdatacenters.com"

# Get current user license state
Write-Host "`nChecking current licenses for $($testUserEmail)..." -ForegroundColor Cyan
try {
    $testUser = Get-MgUser -UserId $testUserEmail -Property UserPrincipalName,AssignedLicenses
    $userLicenses = Get-MgUserLicenseDetail -UserId $testUserEmail
    
    Write-Host "Current licenses:" -ForegroundColor Yellow
    $userLicenses | Format-Table -Property SkuId, SkuPartNumber
}
catch {
    Write-Host "Error finding test user: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Verify test user has E3 license
$hasE3 = $userLicenses.SkuId -contains $E3_SKU
if (-not $hasE3) {
    Write-Host "`nTest user does not have an E3 license! Exiting..." -ForegroundColor Red
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
$hasE5 = $updatedUserLicenses.SkuId -contains $E5_SKU

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
