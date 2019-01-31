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
We use the 'invoke-sqlcmd2' module to allow the usage of PSCredential object for authentication. The latest version (at the time of writing) is included in the 'GenericFunctions' module.

# Installation
- Copy all content of the 'Modules' folder to:
    - c:\Program files\WindowsPowershell\Modules OR
    - c:\users\YOUR_USERNAME\documents\WindowsPowershell\Modules
    
- Fix the paths used in the 'GenerateDBOverview' script to your own environment.
- Run 'GenerateDBOverview'.

# TODO
- Support Windows authentication for connection to SQL
- Rewrite 'GenerateDBOverview' as a function to support all file locations provided as variables
- Write entry to log when DB is not present in the 'master' but is in the 'infodb'. Reverse situation is allready implemented.


