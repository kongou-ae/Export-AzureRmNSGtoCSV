$ErrorActionPreference = "stop"

Login-AzureRmAccount
$subscriptionId = (Get-AzureRmSubscription | Out-GridView -PassThru).SubscriptionId
Select-AzureRmSubscription -Subscription $subscriptionId

$now = Get-Date -Format yyyyMMdd-HHmm
$folder = New-Item -ItemType Directory $HOME/$now
Write-Output "Generated $($folder.FullName)"

$NSGs = Get-AzureRmNetworkSecurityGroup

foreach($NSG in $NSGs){
    $securityRules = New-Object  System.Collections.ArrayList

    foreach($rule in $NSG.SecurityRules ){
        $securityRules.Add($rule) > $null
    }

    foreach($rule in $NSG.DefaultSecurityRules){
        $securityRules.Add($rule) > $null
    }

    $CsvName = $HOME + "/" + $now + "/" + $NSG.Name + ".csv"

    $securityRules = $securityRules | Sort-Object -Property Direction,Priority
    $securityRules | Select-Object `
        Direction,
        Priority,
        Name,
        @{Label="SourceAddressPrefix"; Expression={ $_.SourceAddressPrefix -join ","}},
        @{Label="SourcePortRange"; Expression={ $_.SourcePortRange -join ","}},
        @{Label="DestinationAddressPrefix"; Expression={ $_.DestinationAddressPrefix -join ","}},
        Protocol,
        @{Label="DestinationPortRange"; Expression={ $_.DestinationPortRange -join ","}},
        Access | Export-Csv -NoTypeInformation -Path $CsvName

    Write-Output "Generated $CsvName"
}
