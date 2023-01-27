$settingsJson = Get-Content -Path params.json | ConvertFrom-Json
$resourceGroupName = $settingsJson.resourceGroupName
$location = $settingsJson.location

New-AzResourceGroup -Name $resourceGroupName -Location $location
$out = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile main.bicep

Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $out.outputs.vmName.value -CommandId 'RunPowerShellScript' -ScriptPath 'vm-commands/Install-VSCode.ps1'
