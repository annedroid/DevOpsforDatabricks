<#
.SYNOPSIS
Find a Job ID by Name

.DESCRIPTION
Find a Job ID by Name

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER JobName
The Name of the job to search for


.EXAMPLE
PS C:\> Get-DatabricksJobId -BearerToken $BearerToken -Region $Region -JobName "MyTestJob"

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Get-DatabricksJobId
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$JobName
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    Try {
        $Jobs = Invoke-RestMethod -Method Get -Uri "https://$Region.azuredatabricks.net/api/2.0/jobs/list" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    Return ($Jobs | where-object {$_.settings.name -eq "$JobName"}).job_id
}
    