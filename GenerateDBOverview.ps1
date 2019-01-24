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
    Write-LogMessage -severity 'Info' -LogMessage "Connecting to $SQLInstance"
    try{
        $databasesinfo = invoke-sqlcmd2 -ServerInstance $SQLInstance -Database "infodb" -Query "select * from overzichtdatabases" -Credential $credential -erroraction stop
        $DatabasesPresent = invoke-sqlcmd2 -ServerInstance $SQLInstance -Database "master" -Query "SELECT name FROM dbo.sysdatabases where name not in ('master','tempdb','model','msdb','infodb')" -Credential $credential -erroraction stop
    }catch{
        switch -wildcard($error[0]){
        "*error: 40*"{Write-LogMessage -Severity 'Warning' -LogMessage "Could not connect to $SQLInstance, check for network connectivity"}
        "*Login failed for user*" {Write-LogMessage -Severity 'Warning' -LogMessage "Could login on $SQLInstance with user $($credential.username)"}
        default {Write-LogMessage -Severity 'Error' -LogMessage "An unidentified error occurered whilst connecting to $SQLInstance. Full message: $($Error[0])"}
        }
        continue
    }
    
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



