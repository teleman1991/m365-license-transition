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

# Get all available SKUs first
Write-Host "`nAll available licenses in tenant:" -ForegroundColor Cyan
$allSkus = Get-MgSubscribedSku
$allSkus | Format-Table -Property SkuId, SkuPartNumber, ConsumedUnits, PrepaidUnits

# Define test user
$testUserEmail = "amadmin@compassdatacenters.com" # Replace with your test user's email

# Get current user license state
Write-Host "`nFetching current licenses for $($testUserEmail)..." -ForegroundColor Cyan
try {
    $testUser = Get-MgUser -UserId $testUserEmail -Property UserPrincipalName,AssignedLicenses
    Write-Host "User found. Fetching detailed license information..." -ForegroundColor Green
    
    $userLicenses = Get-MgUserLicenseDetail -UserId $testUserEmail
    Write-Host "`nDetailed license information:" -ForegroundColor Yellow
    $userLicenses | Format-List -Property SkuId, SkuPartNumber, ServicePlans

    # Pause for review
    Write-Host "`nReview the license information above and press Enter to continue..." -ForegroundColor Cyan
    Read-Host
}
catch {
    Write-Host "Error finding test user: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Display E3 and E5 SKUs we're looking for
Write-Host "`nWe will be looking for these SKUs:" -ForegroundColor Yellow
Write-Host "E3: compassdatacenter:SPE_E3"
Write-Host "E5: compassdatacenter:Microsoft_365_E5_(no_Teams)"

Write-Host "`nDo you want to continue with the license transition? (Y/N)" -ForegroundColor Yellow
$continue = Read-Host

if ($continue -ne "Y") {
    Write-Host "Script terminated by user." -ForegroundColor Yellow
    exit
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
