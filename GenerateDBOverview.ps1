
import-module ./logging.ps1
import-module ./functions.ps1
New-LogWriter -Location C:\Temp\Scripts\ -Type "DBReport"



#Fetch the servers
$ServerInfo = get-csv -CSVLocation "C:\Temp\Scripts\SERVERS.csv"

#Make a list of all domains
$domains = $ServerInfo | Sort-Object -Property Domain -Unique | select Domain

#Get the SQL credential
$credential = get-cred -CredLocation "C:\Temp\Scripts\CredentialSQL.xml"


foreach ($server in $ServerInfo){
    switch ($server.domain){
        "core.local" {$WindowsAuth = $true}
        default {$WindowsAuth = $false}
    }

    ##TODO Windows auth
    <#
    if ($WindowsAuth){
        $credential = Import-Clixml C:\Temp\Scripts\Credential.xml
        $credential.username
    }else{
        $credential = Import-Clixml C:\Temp\Scripts\CredentialSQL.xml
        $credential.username
    }
    #>


    switch($server.INSTANCE){
        ""{$SQLInstance = $server.SERVER}
        default{$SQLInstance = ($server.SERVER +"." + $server.DOMAIN + "\" + $server.INSTANCE)}
    }
    write-host "Connecting to $SQLInstance"
    $databasesinfo = invoke-sqlcmd2 -ServerInstance $SQLInstance -Database "infodb" -Query "select * from overzichtdatabases" -Credential $credential
    $DatabasesPresent = invoke-sqlcmd2 -ServerInstance $SQLInstance -Database "master" -Query "SELECT name FROM dbo.sysdatabases where name not in ('master','tempdb','model','msdb','infodb')" -Credential $credential
    
    foreach($db in $databasesinfo){
        
       $db | select @{Name = "SQL Instance"; Expression = {$SQLInstance}}, databasename, responsible, description, applicatie, subapplicatie, extra-info  | Export-Csv -Path C:\Temp\scripts\databases.csv -Append -NoTypeInformation

       $DatabasesPresent | ?{$_.name -notin $db.databasename} | %{$DatabasesPresent = ($DatabasesPresent | where {$_.name -ne $db.databasename})}

    }

    foreach($dbp in $DatabasesPresent){
       # Write-Host -ForegroundColor Red ($DatabasesPresent | select Name)
        Write-LogMessage -Severity "Info" -LogMessage "Database: $($dbp.name) has no extra info in the infodb on $($SQLInstance)"
    }

}


Finish-Logwriter



