
$ErrorActionPreference = "Stop"
Write-Host "Importing Web App mapping CSV"
$Mappings = Import-Csv -Path .\WebAppMapping.csv
Write-Host "Successfully imported" -ForegroundColor Green

Write-host "Creating Backup directory"
New-Item ./Backups -ItemType Directory -Force
Write-host "Backup directory created successfully"

$Mappings | ForEach-Object {
    if($_.Slot -eq "Prod") {
        Write-Host "Checking Az powerShell context"
        $Context = Get-AzContext
        If($Context.Subscription.Id -ne $_.OldSubscriptionId)
        {
            Write-Host "Context not configured for required subscription:" $_.OldSubscriptionId
            Write-Host "Initiating context configuration"
            Set-AzContext -SubscriptionId $_.OldSubscriptionId
        }
        else{
            Write-Host "Context already configured for subscription" $_.OldSubscriptionId
        }

    Write-Host "Collecting Configuration of old web app:" $_.OldWebApp "Slot:" $_.Slot
    $Webapp = Get-AzWebApp -ResourceGroupName $_.OldResourceGroupName -Name $_.OldWebApp

    Write-Host "Creating backup files of web app configuration"
    $AppSettingsFile = "./Backups/" + $_.OldWebApp + "-" + $_.Slot + "-AppSettings.Json"
    $ConnectionStringFile = "./Backups/" + $_.OldWebApp + "-" + $_.Slot + "-ConnectionStrings.Json"
   
    $Webapp.SiteConfig.AppSettings | ConvertTo-Json | Out-File $AppSettingsFile -Force
    $Webapp.SiteConfig.ConnectionStrings | ConvertTo-Json | Out-File $ConnectionStringFile -Force
    Write-Host "Backup successfull for web app:" $_.OldWebApp "Slot:" $_.Slot
    }
    else
    {
        $Context = Get-AzContext
        If($Context.Subscription.Id -ne $_.OldSubscriptionId)
        {
            Write-Host "Context not configured for required subscription:" $_.OldSubscriptionId
            Write-Host "Configuring"
            Set-AzContext -SubscriptionId $_.OldSubscriptionId
        }
        else{
            Write-Host "Context already configured for subscription" $_.OldSubscriptionId
        }
    Write-Host "Collecting Configuration of old web app:" $_.OldWebApp "Slot:" $_.Slot
    $Webapp = Get-AzWebAppSlot -ResourceGroupName $_.OldResourceGroupName -Name $_.OldWebApp -Slot $_.Slot

  Write-Host "Creating backup files of web app configuration"
    $AppSettingsFile = "./Backups/" + $_.OldWebApp + "-" + $_.Slot + "-AppSettings.Json"
    $ConnectionStringFile = "./Backups/" + $_.OldWebApp + "-" + $_.Slot + "-ConnectionStrings.Json"

    $Webapp.SiteConfig.AppSettings | ConvertTo-Json | Out-File $AppSettingsFile -Force
    $Webapp.SiteConfig.ConnectionStrings | ConvertTo-Json | Out-File $ConnectionStringFile -Force
    Write-Host "Backup successfull for web app:" $_.OldWebApp "Slot:" $_.Slot

    }
}
