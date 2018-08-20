$ErrorActionPreference = "stop"

Login-AzureRmAccount
$subscriptionId = (Get-AzureRmSubscription | Out-GridView -PassThru).SubscriptionId
Select-AzureRmSubscription -Subscription $subscriptionId

$now = Get-Date -Format yyyyMMdd-hhmm
$folder = New-Item -ItemType Directory $HOME/$now
Write-Output "Generated $($folder.FullName)"

$NSGs = Get-AzureRmNetworkSecurityGroup

foreach($NSG in $NSGs){
    $securityRules = New-Object  System.Collections.ArrayList

    foreach($rule in $NSG.SecurityRules | Sort-Object Priority,Direction ){
        $securityRules.Add($rule) > $null
    }

    foreach($rule in $NSG.DefaultSecurityRules){
        $securityRules.Add($rule) > $null
    }

    $CsvName = $HOME + "/" + $now + "/" + $NSG.Name + ".csv"

    $securityRules | Select-Object `
        Direction,
        Priority,
        @{Label="SourceAddressPrefix"; Expression={ $_.SourceAddressPrefix -join ","}},
        @{Label="SourcePortRange"; Expression={ $_.SourcePortRange -join ","}},
        @{Label="DestinationAddressPrefix"; Expression={ $_.DestinationAddressPrefix -join ","}},
        @{Label="DestinationPortRange"; Expression={ $_.DestinationPortRange -join ","}},
        Protocol,
        Access,
        Description | Export-Csv -NoTypeInformation -Path $CsvName

    Write-Output "Generated $CsvName"
}
