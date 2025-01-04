param (    
    [string]
    $organizationUrl,
    
    [string]
    $projectName,

    [System.Collections.Hashtable]
    $header,

    [string]        
    $builtBefore,

    [string]        
    $builtAfter,

    [int]
    $maxResults,

    [string]
    $name,

    [ValidateNotNull]
    [string]
    $apiVersion = '7.1'
)

#Validate input
if ((-not $organizationUrl) -or (-not $projectName) -or (-not $header)) {
    throw "Parameters 'organizationUrl', 'projectName' and 'header' are mandatory."
}
    
#Base query url, which will ensure that property 'process' (classic vs yaml), and latest builds are part of the response
$url = "$organizationUrl/$projectName/_apis/build/definitions/?"

if ($builtBefore) {
    $url = $url + "notBuiltAfter=$builtBefore&"
}

if ($builtAfter) {
    $url = $url + "builtAfter=$builtAfter&"
}

if ($name) {
    $url = $url + "name=*$name*&" #asterisk to denote wildcard 
}

if ($maxResults) {
    $url = $url + "`$top=$maxResults&" 
}    

$url = $url + "api-version=$apiVersion"

try {
    $buildDefinitions = Invoke-RestMethod -Method Get -Uri $url -Headers $header -ContentType "application/json"
}
catch {
    # Invoke-RestMethod may throw System.Net.WebException
    Write-Error "Statuscode: $($_.Exception).Response.StatuCode"       
    exit 1
}

$buildDefinitions.value | Select-Object Id, Name
