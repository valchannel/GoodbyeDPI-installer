@echo     1. Checking for administrator priviliges... & net session 1>nul 2>nul || (powershell start-process "%~f0" -Verb RunAs & goto :EOF)
@powershell -ExecutionPolicy Bypass -Command Invoke-Expression $('$args=@(^&{$args} %*);'+[String]::Join(';',(Get-Content '%~f0') -notmatch '^^@powershell.*EOF$^|^^@echo.*EOF\)$')) & goto :EOF
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()
echo "    2. Checking if GoodbyeDPI is installed..."
if (Get-Service -Name GoodbyeDPI -ErrorAction SilentlyContinue) {
$msg1 = [System.Windows.Forms.MessageBox]::Show("GoodbyeDPI is already installed.`n`nDelete GoodbyeDPI?", "GoodbyeDPI installer", 4, "Question")
if ($msg1 -eq 'No') { exit } else {
echo "       Terminating previous installation..."
try { Stop-Service -name "GoodbyeDPI" 2>&1 | Out-Null } catch {}
try { Stop-Service -name "WinDivert" 2>&1 | Out-Null } catch {}
sc.exe delete "GoodbyeDPI" | out-null
sc.exe delete "WinDivert" | out-null
$msg2 = [System.Windows.Forms.MessageBox]::Show("GoodbyeDPI is deleted.`n`nReboot PC?", "GoodbyeDPI installer", 4, "Exclamation")
if ($msg2 -eq 'Yes') { Restart-Computer } else {
$msg3 = [System.Windows.Forms.MessageBox]::Show("Reinstall GoodbyeDPI?", "GoodbyeDPI installer", 4, "Question")
if ($msg3 -eq 'No') { exit } } } }
echo "    3. Getting latest version at github.com/ValdikSS/GoodbyeDPI..."
$releasesResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases"
$latestRelease = $releasesResponse | Sort-Object -Property { [datetime]$_.created_at } -Descending | Select-Object -First 1
$asset = $latestRelease.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
echo "    4. Downloading $($asset.browser_download_url)..."
$installPath = "$($env:programdata)\GoodbyeDPI"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile ( New-Item -Path "$($installPath)\$($asset.name)" -Force )
Push-Location -Path $installPath
echo "    5. Extracting to $($installPath)..."
Expand-Archive -Path $asset.name -Force
Push-Location -Path $([System.IO.Path]::GetFileNameWithoutExtension($asset.name))
$subdir = Get-ChildItem -Directory | Select-Object -First 1 -ExpandProperty Name
Push-Location $subdir
echo "    6. Applying MGTS patch..."
$filePath = "service_install_russia_blacklist_YOUTUBE_ALT.cmd"
$pattern = "-5 -e1 -q"
$replacement = "-7 -e1 -f1 -q"
$content = Get-Content -Path $filePath -Raw
$newContent = $content -replace [regex]::Escape($pattern), $replacement
Set-Content -Path $filePath -Value $newContent -Force
echo "    7. Installing latest version..."
Start-Process -FilePath "cmd" -ArgumentList "/c echo.|$($filepath) 1>nul 2>nul"
if ( $? -eq $true ) { echo "    OK!" } else { [System.Windows.MessageBox]::Show("Error!`n`nYou have to install a VPN service :(", "GoodbyeDPI installer", "OK", "Critical") }
Pop-Location
Pop-Location
Remove-Item -Path $asset.name
$msg4 = [System.Windows.Forms.MessageBox]::Show("GoodbyeDPI installed.`n`nOpen Youtube to test?" , "GoodbyeDPI installer" , 4, "Question")
if ($msg4 -eq 'Yes') { Start-Process -filePath "https://youtube.com" }