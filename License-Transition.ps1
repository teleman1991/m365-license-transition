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

# Get all users with E3 licenses
Write-Host "Getting users with E3 licenses..." -ForegroundColor Cyan
$E3Users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $E3_SKU)" -All

# Initialize counters
$totalUsers = $E3Users.Count
$processedUsers = 0
$successfulE5Adds = 0
$failedE5Adds = 0
$successfulE3Removals = 0
$failedE3Removals = 0

Write-Host "Found $totalUsers users with E3 licenses." -ForegroundColor Green

# Process each user
foreach ($user in $E3Users) {
    $processedUsers++
    $percentComplete = [math]::Round(($processedUsers / $totalUsers) * 100, 2)
    
    Write-Host "`nProcessing user $processedUsers of $totalUsers ($percentComplete%)"
    Write-Host "User: $($user.UserPrincipalName)" -ForegroundColor Cyan

    # Add E5 license
    try {
        Write-Host "Adding E5 license..." -NoNewline
        $params = @{
            addLicenses = @(
                @{
                    skuId = $E5_SKU
                }
            )
            removeLicenses = @()
        }
        Set-MgUserLicense -UserId $user.UserPrincipalName -BodyParameter $params
        Write-Host "Success!" -ForegroundColor Green
        $successfulE5Adds++
    }
    catch {
        Write-Host "Failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        $failedE5Adds++
        continue
    }

    # Wait for license propagation
    Write-Host "Waiting for license propagation..." -NoNewline
    Start-Sleep -Seconds 30
    Write-Host "Done!"

    # Verify E5 license was added successfully
    $updatedUserLicenses = Get-MgUserLicenseDetail -UserId $user.UserPrincipalName
    $hasE5 = $updatedUserLicenses.SkuId -contains $E5_SKU

    if ($hasE5) {
        # Remove E3 license
        try {
            Write-Host "Removing E3 license..." -NoNewline
            $params = @{
                addLicenses = @()
                removeLicenses = @(
                    $E3_SKU
                )
            }
            Set-MgUserLicense -UserId $user.UserPrincipalName -BodyParameter $params
            Write-Host "Success!" -ForegroundColor Green
            $successfulE3Removals++
        }
        catch {
            Write-Host "Failed!" -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            $failedE3Removals++
        }
    }
    else {
        Write-Host "E5 license verification failed. Skipping E3 removal." -ForegroundColor Red
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

# Disconnect from Microsoft Graph
Disconnect-MgGraph