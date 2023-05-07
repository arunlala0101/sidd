# Select Azure subscription
az account set `
    --subscription $Env:AZURE_SUBSCRIPTION_NAME

Write-Host "Check Subcription name :"$env:AZURE_SUBSCRIPTION_NAME
Write-Host "check FirewallRuleEndIPAddress :"$env:FirewallRuleEndIPAddress
Write-Host "check Environment :"$env:ENVIRONMENT

#param(  [string]$SqlServerAdminPassword )

$SqlServerAdminPassword = "z44ws1raiXmKUho3GKEs"

Write-Host "ResourceGroupName :"$env:ResourceGroupName
Write-Host "Location :"$env:Location
Write-Host "SqlServerName :"$env:SqlServerName
Write-Host "SqlServerVersion :"$env:SqlServerVersion
Write-Host "SqlServerDatabaseName :"$env:SqlServerDatabaseName
Write-Host "SqlServerDatabaseEdition :"$env:SqlServerDatabaseEdition
Write-Host "SqlServerAllFirewallRuleName :"$env:SqlServerAllFirewallRuleName
Write-Host "SqlServerFirewallRuleName :"$env:SqlServerFirewallRuleName
Write-Host "SqlServerAdminName :"$env:SqlServerAdminName
Write-Host "SqlServerAdminPassword :"$SqlServerAdminPassword
Write-Host "FirewallRuleStartIPAddress :"$env:FirewallRuleStartIPAddress
Write-Host "FirewallRuleEndIPAddress :"$env:FirewallRuleEndIPAddress

#check to see if the resource group exists, if not create it
$resource_group = Get-AzResourceGroup -Name $env:ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($resource_group) {
    Write-Host "This resource group already exists, the command has been skipped"
} else {
    Write-Host "Creating a new resource group"
    New-AzResourceGroup -Name $env:ResourceGroupName -Location $env:Location
}

#check to see if the azure sql server exists, if not create it
$azure_sql_server = Get-AzSqlServer -ServerName $env:SqlServerName -ResourceGroupName $env:ResourceGroupName -ErrorAction SilentlyContinue

if($azure_sql_server) {
    Write-Host "This azure sql server already exists, the command has been skipped"
} else {
    Write-Host "Creating a new azure sql server"
   
    #convert the password to a secure string since creating a PSCredential object requires it
    $secure_password = ConvertTo-SecureString -String $SqlServerAdminPassword -AsPlainText -Force
    Write-Host "secure_password :"$secure_password
    #create the PSCredential object to pass to the New-AzSqlServer cmdlet
    $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:SqlServerAdminName, $secure_password
   
    New-AzSqlServer -ResourceGroupName $env:ResourceGroupName -Location $env:LOCATION -ServerName $env:SqlServerName -ServerVersion $env:SqlServerVersion -SqlAdministratorCredentials $credentials
}

#check to see if the azure sql server firewall rules exists, if not create them
$azure_firewall_rules = Get-AzSqlServerFirewallRule -ResourceGroupName $env:ResourceGroupName -ServerName $env:SqlServerName -ErrorAction SilentlyContinue

if($azure_firewall_rules) {
    Write-Host "The azure sql server firewall rules already exists, the command has been skipped"
} else {
    Write-Host "Creating a new azure sql server firewall rule"
    New-AzSqlServerFirewallRule -ResourceGroupName $env:ResourceGroupName -ServerName $env:SqlServerName -FirewallRuleName $env:SqlServerAllFirewallRuleName -StartIPAddress 0.0.0.0 -EndIPAddress 0.0.0.0
   
    Write-Host "Creating a new azure sql server firewall rule"
    New-AzSqlServerFirewallRule -ResourceGroupName $env:ResourceGroupName -ServerName $env:SqlServerName -FirewallRuleName $env:SqlServerFirewallRuleName -StartIPAddress $env:FirewallRuleStartIPAddress -EndIPAddress $env:FirewallRuleEndIPAddress
}

#check to see if the azure sql server database exists, if not create it
$azure_database = Get-AzSqlDatabase -ResourceGroupName $env:ResourceGroupName -ServerName $env:SqlServerName -DatabaseName $env:SqlServerDatabaseName -ErrorAction SilentlyContinue

if($azure_database) {
    Write-Host "This azure sql server database already exists, the command has been skipped"
} else {
    Write-Host "Creating a new azure sql server database"
    New-AzSqlDatabase -ResourceGroupName  $env:ResourceGroupName -ServerName $env:SqlServerName -DatabaseName $env:SqlServerDatabaseName -Edition $env:SqlServerDatabaseEdition