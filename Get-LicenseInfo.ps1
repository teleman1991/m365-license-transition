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

# Get all available SKUs and format them nicely
Write-Host "`nAll available licenses in tenant:" -ForegroundColor Cyan
$allSkus = Get-MgSubscribedSku
$allSkus | Sort-Object -Property SkuPartNumber | Format-Table -Property SkuId, SkuPartNumber, ConsumedUnits, @{Name='AvailableUnits';Expression={$_.PrepaidUnits.Enabled - $_.ConsumedUnits}}

# Search for Teams Premium specifically
Write-Host "`nSearching for Teams Premium licenses:" -ForegroundColor Yellow
$teamsLicenses = $allSkus | Where-Object { 
    $_.SkuPartNumber -like "*TEAMS*" -or 
    $_.SkuPartNumber -like "*PREMIUM*" -or 
    $_.ServicePlans.ServicePlanName -like "*TEAMS*PREMIUM*"
}

if ($teamsLicenses) {
    Write-Host "Found potential Teams Premium licenses:" -ForegroundColor Green
    $teamsLicenses | Format-Table -Property SkuId, SkuPartNumber
    
    # Show service plans for these licenses
    foreach ($license in $teamsLicenses) {
        Write-Host "`nService plans for $($license.SkuPartNumber) ($($license.SkuId)):" -ForegroundColor Cyan
        $license.ServicePlans | Format-Table -Property ServicePlanId, ServicePlanName
    }
} else {
    Write-Host "No Teams Premium licenses found." -ForegroundColor Red
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph