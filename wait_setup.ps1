while (Get-Process -Name setup -ErrorAction SilentlyContinue) { Start-Sleep -Seconds 5 }
Write-Output "SETUP_DONE"
