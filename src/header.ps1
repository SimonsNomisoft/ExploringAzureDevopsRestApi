function New-Header {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pat
    )

    # When providing PAT through header, the PAT - prepended by a colon - must be converted to base64 string.
    $patBase64 = [Convert]::ToBase64String([char[]]":$pat")
    $header = @{authorization = "Basic $patBase64" }

    #----------------------Alternative----------------------
    # $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    # $headers.Add("Authorization", "Basic $patBase64")
    #----------------------End Alternative----------------------


    Write-Output $header
}


# Resources:
# https://www.opentechguides.com/how-to/article/azure/201/devops-rest-powershell.html