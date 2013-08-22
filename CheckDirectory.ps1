param($folder)

# Slightly modified from @davor's comment in 
# http://stackoverflow.com/questions/10521061/how-to-get-a-md5-checksum-in-powershell
function md5($file) {
	$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	[System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::Open("$file",[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)))
}

# Setup file names and locations.
$resultsFolder = (Get-Location).ToString() + "\results\" + $folder.Replace("\", "-").Replace(":", "") + "\"
$resultsFilePath = $resultsFolder + (Get-Date -format "yyyy-MM-dd HH.mm.ss").ToString() + ".txt"
$prevFileName = "!_previous snapshot.csv"
$prevFilePath = $resultsFolder + $prevFileName
$currFilePath = $resultsFolder + "!_current snapshot.csv"

# Create results folder if it doesn't exist.
New-Item -ItemType Directory -Force -Path $resultsFolder

# Remove old snapshot and rename the now old "current" snapshot.
if (Test-Path $prevFilePath) { Remove-Item $prevFilePath }
if (Test-Path $currFilePath) { Rename-Item $currFilePath $prevFileName }

# Create new current snapshot.
"File|Hash" > $currFilePath
Get-ChildItem $folder -File -Recurse | % { 
	$file = $_.FullName
	$hash = md5($file)
	Add-Content $currFilePath "$file|$hash"
}

if (!(Test-Path $prevFilePath)) {
	"Initial snapshot created. No previous snapshot to compare." | Out-File $resultsFilePath 
	Exit
}

# Compare
$previousSnapshot = Import-Csv $prevFilePath  -delimiter '|'
$currentSnapshot = Import-Csv $currFilePath -delimiter '|'
$comparison = Compare-Object $previousSnapshot $currentSnapshot -Property File,Hash | Group-Object -Property File |  % { 
	$status = "Modified"
	if($_.group.Count -eq 1 -and $_.group[0].SideIndicator -eq "=>") { $status = "Added" }
	if($_.group.Count -eq 1 -and $_.group[0].SideIndicator -eq "<=") { $status = "Deleted" }
	New-Object -TypeName psobject -Property @{ File=$_.name;Status = $status }
}

# Results
if(($comparison | measure).Count -eq 0) {
	"No changes since last CheckDirectory run." | Out-File $resultsFilePath
	Exit
}

$formatted = $comparison | Sort-Object File,Status | Format-Table -Wrap -AutoSize
$formatted | Out-File $resultsFilePath
