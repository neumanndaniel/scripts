[CmdletBinding()]
param (
  [Parameter(Mandatory = $true, HelpMessage = 'Azure region')]
  [String]
  $Location,
  [Parameter(Mandatory = $false, HelpMessage = 'E.g. Dsv3')]
  [String]
  $Family = ""
)

function Get-OsDiskSize ($Size) {
  if ($Size -gt 2048) {
    return 2048
  }
  else {
    return $Size
  }
}
function Get-Skus ($Location) {
  $EphemeralOsDisk = @()
  $Skus = Get-AzComputeResourceSku -Location $Location | Where-Object { $_.ResourceType -eq "virtualMachines" } | Where-Object { $null -eq $_.Restrictions.ReasonCode }
  foreach ($Sku in $Skus) {
    if (($Sku.Capabilities | Where-Object { $_.Name -eq "EphemeralOSDiskSupported" }).Value -eq $true -and ($Sku.Capabilities | Where-Object { $_.Name -eq "PremiumIO" }).Value -eq $true -and $null -ne ($Sku.Capabilities | Where-Object { $_.Name -eq "CachedDiskBytes" }).Value) {
      $VmSku = New-Object PSObject -Property @{
        Name                     = $Sku.Name
        Family                   = $Sku.Family -replace "standard", "" -replace "Family", "" -replace " ", ""
        EphemeralOsDiskSupported = [bool]($Sku.Capabilities | Where-Object { $_.Name -eq "EphemeralOSDiskSupported" }).Value
        MaxEphemeralOsDiskSizeGb = Get-OsDiskSize -Size (($Sku.Capabilities | Where-Object { $_.Name -eq "CachedDiskBytes" }).Value / 1GB)
      }
      $EphemeralOsDisk += $VmSku
    }
  }
  return $EphemeralOsDisk
}

$Result = Get-Skus -Location $Location

if ($Family -ne "") {
  $Result | Where-Object { $_.Family -eq $Family } | Select-Object -Property Name, Family, MaxEphemeralOsDiskSizeGb, EphemeralOsDiskSupported | ConvertTo-Json
}
else {
  $Result | Select-Object -Property Name, Family, MaxEphemeralOsDiskSizeGb, EphemeralOsDiskSupported | ConvertTo-Json
}