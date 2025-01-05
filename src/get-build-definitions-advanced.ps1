
#Requires -Version 7.0

enum PipelineType {
    Both
    Classic
    YAML
    Unknown  
}

function Get-BuildDefinitions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidatePattern("^https://")]
        [string]
        $organizationUrl,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $projectName,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        $header,

        [parameter(Mandatory = $false)]
        [string]        
        [ValidatePattern("\d{4}-\d{2}-\d{2}", ErrorMessage = "Enter date in format 'yyyy-MM-dd'")]
        $builtBefore,

        [parameter(Mandatory = $false)]
        [string]        
        [ValidatePattern("\d{4}-\d{2}-\d{2}", ErrorMessage = "Enter date in format 'yyyy-MM-dd'")]
        $builtAfter,

        [parameter(Mandatory = $false)]
        [int]
        $maxResults,

        [parameter(Mandatory = $false, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $name,

        [parameter(Mandatory = $false)]
        [PipelineType]
        $pipelineType,

        [parameter(Mandatory = $false)]
        [string]
        $apiVersion = '7.1'
    )
    
    #Base query url, which will ensure that property 'process' (classic vs yaml), and latest builds are part of the response
    $url = "$organizationUrl/$projectName/_apis/build/definitions/?includeAllProperties=true&includeLatestBuilds=true&"

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
    
    switch ($pipelineType) {             
        "Classic" {
            $url = $url + "processType=1&"             
        } 
        "YAML" {
            $url = $url + "processType=2&"             
        } 
        default {            
        } #All pipeline types, which is the default hence no extra argument
    } 
    
    $url = $url + "api-version=$apiVersion"    
    
    Write-Verbose "Verbose url: $url"
    Write-Debug "Debug url: $url"
    
    try {
        $buildDefinitions = Invoke-RestMethod -Method Get -Uri $url -Headers $header -ContentType "application/json"
    }
    catch {
        # Invoke-RestMethod may throw System.Net.WebException
        Write-Error "Statuscode: $($_.Exception).Response.StatuCode"       
        exit 1
    }

    $total = @()
   
    foreach ($buildDefinition in $buildDefinitions.value) {
        $pipelineType = switch ($buildDefinition.process.type) {
            1 { [PipelineType]::Classic }
            2 { [PipelineType]::YAML }
            default { [PipelineType]::Unknown }
        }
                
        $pipeline = [PSCustomObject]@{
            Id   = $buildDefinition.Id
            Name = $buildDefinition.Name            
            Type = $pipelineType            
        }
       
        $total += $pipeline       
    }    
    
    Write-Output $total    
}
