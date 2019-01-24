# GenerateDBOverview
This script will take a CSV file in the format found in CSV file 'Example.csv'.

# Detailed description
The script takes a CSV file with server names, instance names and domain names.
After loading the instances a PS Credential will be imported (Import-CliXml).

This SQL Credential will be used to connnect to all instances and do 2 queries:
- Fetch all current databases from (master.dbo.sys.databases)
- Fetch all custom database info from a table in the 'infodb'

The infodb table is called 'overzichtdatabases' and contains the following columns:
- databasename
- responsible
- description
- applicatie
- subapplicatie
- extra-info

It will compare all databases found in the 'infodb' with the databases from 'master'.
- For each database in master but not in infodb it will write an entry to the logfile explaining a new database is found on the system and more info is needed.

After this it will create an CSV file as output with all databases from all instances with their info.
This CSV file can be used for other purposes like generating a webpage or can serve as input for another script.

Also logging is included to catch critical errors and foresee debugging.

# Dependencies
We use the 'invoke-sqlcmd2' module to allow the usage of PSCredential object for authentication. The CMDLet is included in 'functions.ps1' to allow standalone usage without internet connection.
