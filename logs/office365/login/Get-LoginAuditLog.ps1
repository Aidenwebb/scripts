<#
.SYNOPSIS
    This script collects all available login audit logs from Microsoft Graph and outputs then in to a CSV.
#>
param(
    [switch]$returnResult = $global:returnResult,
    [switch]$exportCSV
    
)

# Connect to Microsoft Graph with the required permissions
Write-Host "Connecting to Microsoft Graph"
Connect-MgGraph -Scopes "AuditLog.Read.All" -NoWelcome

# Query sign-in logs
Write-Host "Querying Sign in logs. Please wait, this may take some time..."
$signins = Get-MgAuditLogSignIn | Select-Object CreatedDateTime, AppDisplayName, AppId, ClientAppUsed, ConditionalAccessStatus, AppliedConditionalAccessPolicies, DeviceDetail, IsInteractive, UserDisplayName, UserPrincipalName, Status, IPAddress, Location

# Create an array to store processed results
$loginResults = @()

# Process each sign-in record
foreach ($signin in $signins) {
    # Capture the sign-in details
    $loginDetails = [PSCustomObject]@{
        Timestamp     = $signin.CreatedDateTime
        Username      = $signin.UserPrincipalName
        "Success/Failure" = if ($signin.Status.ErrorCode -eq 0) { "Success" } else { "Failure" }
        StatusErrorCode = $signin.Status.ErrorCode
        StatusDetails = $signin.Status.AdditionalDetails
        StatusFailureReason = $signin.Status.FailureReason
        IPAddress  = $signin.IPAddress
        Geolocation   = "$($signin.Location.City), $($signin.Location.State), $($signin.Location.CountryOrRegion)"
        IsInteractive = $signin.IsInteractive
        AppDisplayName = $signin.AppDisplayName
        AppId = $signin.AppId
        ClientAppUsed = $signin.ClientAppUsed
        ConditionalAccessStatus = $signin.ConditionalAccessStatus
        AppliedConditionalAccessPolicies = $signin.AppliedConditionalAccessPolicies
        DeviceDetailDisplayName = $signIn.DeviceDetail.DisplayName
        DeviceDetailOperatingSystem = $signIn.DeviceDetail.OperatingSystem
        DeviceDetailTrustType = $signIn.DeviceDetail.TrustType
        DeviceDetailBrowser = $signIn.DeviceDetail.Browser
        DeviceDetailDeviceId = $signIn.DeviceDetail.DeviceId
        DeviceDetailIsCompliant = $signIn.DeviceDetail.IsCompliant
        DeviceDetailIsManaged = $signIn.DeviceDetail.IsManaged

    }
    # Add to results array
    $loginResults += $loginDetails
}

if ($exportCSV) {
    Write-Host "Exporting CSV"
    # Export results to CSV if desired
    $loginResults | Export-Csv -Path "O365_Login_Results.csv" -NoTypeInformation -Encoding UTF8
}

if ($returnResult) {
    # Display results in the console
    $loginResults | Format-Table -AutoSize
}

