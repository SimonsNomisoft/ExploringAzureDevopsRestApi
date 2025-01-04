param (            
    [string]
    $variableGroupName,    
    
    [string]
    $organizationUrl,
    
    [string]
    $projectName, 
    
    [System.Collections.Hashtable]
    $header,               
    
    [string]
    $apiVersion = '7.1'
)      

#Perform validation
if ((-not $variableGroupName) -or `
    (-not $organizationUrl) -or `
    (-not $projectName) -or `
    (-not $header)) {
    throw "Parameters 'variableGroupName', 'organizationUrl', 'projectName' and 'header' are mandatory."
}

$queryString = "groupName=$variableGroupName&api-version=$apiVersion"
$url = "$organizationUrl/$projectName/_apis/distributedtask/variablegroups/?$queryString"
         
try {
    $variableGroupResponse = Invoke-RestMethod -Method Get -Uri $url -Headers $header -ContentType "application/json"    
}
catch {
    # Invoke-RestMethod may throw System.Net.WebException
    Write-Error "Statuscode: $($_.Exception).Response.StatuCode"       
    exit 0
}
       
if ($variableGroupResponse.Count -ne 1) {
    throw "Expected to find one variable group but found $($variableGroupResponse.Count)."      
}

$variableGroup = $variableGroupResponse.value    
$variables = $variableGroup.variables | Get-Member | Select-Object -ExpandProperty Name

Write-Host $variables

    
  

