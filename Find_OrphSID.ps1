Import-Module ActiveDirectory
$orphans = @()
$domain = Get-ADDomain
$sidFilter = "SID=*"
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = [ADSI]"LDAP://$($domain.DistinguishedName)"
$searcher.Filter = $sidFilter
$searcher.PageSize = 1000
$searcher.FindAll() | ForEach-Object {
    $objectSID = New-Object System.Security.Principal.SecurityIdentifier($_.Properties['objectSID'][0],0)
    $sidString = $objectSID.Value
    $distinguishedName = $_.Properties['distinguishedName']
    $class = $_.Properties['objectClass'][0]
    if ($class -ne "computer" -and $class -ne "user" -and $class -ne "group") {
        $orphans += @{
            SID = $sidString;
            DN = $distinguishedName;
            Class = $class
        }
    }
}
$orphans
