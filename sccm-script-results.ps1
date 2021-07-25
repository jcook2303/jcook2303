# Script for retrieving client output of script pushed remotely via SCCM
# Credit to https://www.verboon.info/2019/09/extract-configmgr-script-status-results-with-powershell/ for starting framework
Function Get-SCCMScriptOutput {
    Param (
    [Parameter(Mandatory=$true)]    
    [string]$SiteServer,
    [Parameter(Mandatory=$true)]
    [string]$NameSpace,
    [Parameter(Mandatory=$true)]
    [string]$ScriptName,
    [Parameter(Mandatory=$true)]
    [string]$ClientOpID
    )
        
    $ScriptGUID = (Get-CimInstance -ComputerName $SiteServer -Namespace $Namespace -ClassName SMS_ScriptsExecutionTask `
    | Where-Object -Property ClientOperationId -eq $ClientOpID).ScriptGuid

    $Summary = Get-CimInstance -ComputerName win-sccm-test.int.neuralink.com -Namespace root\SMS\{{SiteName}} -ClassName SMS_ScriptsExecutionSummary `
    | Where-Object -Property ScriptGuid -eq $ScriptGUID | Select -Property ScriptOutput

    # SCCM returns the results for each client as one string
    # This splits the string into hostname and product key strings
    Out-String -InputObject $Summary | foreach {$_ -replace '.*Name":|,*,"OA3XOriginalProductKey"|}.*'} `
    | foreach {$_ -split ":"} | foreach {$_ -replace '"',""}

    Out-File -FilePath .\product-keys.txt -InputObject $Summary
    # Would like to turn it into a CSV file, appending hostname and product key to separate columns

}
