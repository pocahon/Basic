$numofpaths  = 0
$countcopies = 0
$filetocopy  = "testfile.txt"

$myarray = (gi env:path).value.split(';') | Where-Object { $_ -ne '' }

Write-Host ""
Write-Host "[i] Number of folder paths: " $myarray.count

if ($myarray[$myarray.count - 1] -eq "") {
    $numofpaths = $myarray.count - 2
} else {
    $numofpaths = $myarray.count - 1
}

New-Item $filetocopy -type file | Out-Null

$FileExists = Test-Path $filetocopy

if (!$FileExists) {
    Write-Host "[i] Dummy test file used to test access was not outputted: " $filetocopy
    exit
}

Write-Host "[i] Copying and removing the test file to path folders where access is granted"

for ($i = 0; $i -le $numofpaths; $i++) {
    if ($myarray[$i] -ne '' -and (Test-Path -Path $myarray[$i])) {
        Copy-Item $filetocopy $myarray[$i] -ErrorAction SilentlyContinue -ErrorVariable errors

        if ($errors.count -le 0) {
            Write-Host -ForegroundColor Green "      Access granted: " $myarray[$i]
            $countcopies = $countcopies + 1
            $filetoremove = $myarray[$i] + "\" + $filetocopy
            Remove-Item $filetoremove
        } else {
            Write-Host -ForegroundColor Red "      Access denied: " $myarray[$i]
        }
    } else {
        Write-Host -ForegroundColor Blue "      Folder missing: " $myarray[$i]
    }
}

Remove-Item $filetocopy
