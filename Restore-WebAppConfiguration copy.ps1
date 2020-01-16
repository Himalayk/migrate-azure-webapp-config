$ErrorActionPreference = "Stop"
Write-Host "Importing Web App mapping CSV"
$Mappings = Import-Csv -Path .\WebAppMapping.csv
Write-Host "Successfully imported" -ForegroundColor Green

$Mappings | ForEach-Object {
    if($_.Slot -eq "Prod") {
        Write-Host "Checking Az powerShell context"
        $Context = Get-AzContext
        If($Context.Subscription.Id -ne $_.NewSubscriptionId)
        {
            Write-Host "Context not configured for required subscription:" $_.NewSubscriptionId
            Write-Host "Initiating context configuration"
            Set-AzContext -SubscriptionId $_.NewSubscriptionId
        }
        else{
            Write-Host "Context already configured for subscription" $_.NewSubscriptionId
        }

        Write-Host "Collecting configuration values for web app:" $_.OldWebApp "Slot:" $_.Slot
        $AppSettingsFile = "./Backups/" + $_.OldWebApp + "-" + $_.Slot + "-AppSettings.Json"
        $ConnectionStringFile = "./Backups/" + $_.OldWebApp + "-" + $_.Slot + "-ConnectionStrings.Json"

        $AppSettingsFileContent = Get-Content -Path $AppSettingsFile | ConvertFrom-Json
        $ConnectionStringFileContent = Get-Content -Path $ConnectionStringFile | ConvertFrom-Json

        $AppSettingsHashtable = New-Object System.Collections.Hashtable
        $ConnectionStringHashtable = New-Object System.Collections.Hashtable
        

        if(($AppSettingsFileContent -ne $null) -and ($ConnectionStringFileContent -ne $null)){
            Write-Host "Configuring Application Settings and Connection Strings of web app:" $_.NewWebApp "Slot" $_.Slot
            $AppSettingsFileContent | ForEach-Object {$AppSettingsHashtable[$_.Name] = $_.Value}
            $ConnectionStringFileContent | ForEach-Object {$ConnectionStringHashtable[$_.Name] = $_.Value}
            Set-AzWebApp -ResourceGroupName $_.NewResourceGroupName -Name $_.NewWebApp -AppSettings $AppSettingsHashtable 
            Write-Host "Done"
        }
        else{
            # if($ConnectionStringFileContent -ne $null){
            #     Write-Host "Setting Connection Strings of web app:" $_.NewResourceGroupName "Slot" $_.Slot
            #     $ConnectionStringFileContent | ForEach-Object {
            #         $ConnectionStringHashtable[$_.Name] = $_.value 
            #         }
            #     Set-AzWebApp -ResourceGroupName $_.NewResourceGroupName -Name $_.NewWebApp  -ConnectionStrings $ConnectionStringHashtable
            #     Write-Host "Done"
            # }
            if($AppSettingsFileContent -ne $null){
                Write-Host "Configuring Application Settings of web app:" $_.NewWebApp "Slot" $_.Slot
                $AppSettingsFileContent | ForEach-Object {$AppSettingsHashtable[$_.Name] = $_.Value}
                Set-AzWebApp -ResourceGroupName $_.NewResourceGroupName -Name $_.NewWebApp -AppSettings $AppSettingsHashtable
                Write-Host "Done"
            }
        }
    }
    else{
        Write-Host "Collecting configuration values for web app:" $_.OldWebApp "Slot:" $_.Slot
        $AppSettingsFile = "./Backups/" + $_.OldWebApp + "-" + $_.Slot + "-AppSettings.Json"
        $ConnectionStringFile = "./Backups/" + $_.OldWebApp + "-" + $_.Slot + "-ConnectionStrings.Json"

        $AppSettingsFileContent = Get-Content -Path $AppSettingsFile | ConvertFrom-Json
        $ConnectionStringFileContent = Get-Content -Path $ConnectionStringFile | ConvertFrom-Json

        $AppSettingsHashtable = New-Object System.Collections.Hashtable
        $ConnectionStringHashtable = New-Object System.Collections.Hashtable
        

        if(($null -ne $AppSettingsFileContent) -and ($null -ne $ConnectionStringFileContent)){
            Write-Host "Configuring Application Settings and Connection Strings of web app:" $_.NewWebApp "Slot:" $_.Slot
            $AppSettingsFileContent | ForEach-Object {$AppSettingsHashtable["$_.Name"] = "$_.Value"}
           # $ConnectionStringFileContent | ForEach-Object {$ConnectionStringHashtable["$_.Name"] = "$_.Value"}
            Set-AzWebAppSlot -ResourceGroupName $_.NewResourceGroupName -Name $_.NewWebApp -AppSettings $AppSettingsHashtable -Slot $_.Slot
            #-ConnectionStrings $ConnectionStringHashtable
            Write-Host "Done"
        }
        else{
            # if($null -ne $ConnectionStringFileContent){
            #     Write-Host "Setting Connection Strings of web app:" $_.NewResourceGroupName "Slot" $_.Slot
            #     $ConnectionStringFileContent | ForEach-Object {$ConnectionStringHashtable["$_.Name"] = "$_.Value"}
            #     Set-AzWebAppSlot -ResourceGroupName $_.NewResourceGroupName -Name $_.NewWebApp  -ConnectionStrings $ConnectionStringHashtable -Slot $_.Slot
            #     Write-Host "Done"
            # }
            if($null -ne $AppSettingsFileContent){
                Write-Host "Setting Application Settings of web app:" $_.NewResourceGroupName "Slot" $_.Slot
                $AppSettingsFileContent | ForEach-Object {$AppSettingsHashtable["$_.Name"] = "$_.Value"}
                Set-AzWebAppSlot -ResourceGroupName $_.NewResourceGroupName -Name $_.NewWebApp -AppSettings $AppSettingsHashtable -Slot $_.Slot
                Write-Host "Done"
            }
        }
    }
}