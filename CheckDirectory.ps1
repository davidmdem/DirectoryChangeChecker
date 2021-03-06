param($checkPath, $resultPath)

$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDirectory .\CheckDirectoryFunctions.ps1)

# Check input
if($checkPath -eq $null -or  !(Test-Path $checkPath)) {
	outputResult("checkPath is not valid.  The -checkPath parameter has to pass Test-Path.")
}
$checkPath = addSlash($checkPath)

if($resultPath -eq $null) {
	$resultPath = (Get-Location).ToString() + "result\"
} else {
	if(!(Test-Path $resultPath -IsValid)) {
		outputResult("resultPath is not valid.  The -resultPath parameter has to pass Test-Path.")
	}	
	$resultPath = addSlash($resultPath)
}

# Setup files/paths.
$resultFolderPath = $resultPath + $checkPath.Replace("\", "-").Replace(":", "") + "\"
$resultFilePath = $resultFolderPath + (Get-Date -format "yyyy-MM-dd HH.mm.ss").ToString() + ".txt"
$prevSnapName = "!previous snapshot.csv"
$prevSnapPath = $resultFolderPath + $prevSnapName
$currSnapPath = $resultFolderPath + "!current snapshot.csv"

# Create result folder if it doesn't exist.
New-Item -ItemType Directory -Force -Path $resultFolderPath

# Remove old snapshot and rename the now old "current" snapshot.
if (Test-Path $prevSnapPath) { Remove-Item $prevSnapPath }
if (Test-Path $currSnapPath) { Rename-Item $currSnapPath $prevSnapName }

# Create new current snapshot.
"File|Hash" > $currSnapPath
Get-ChildItem $checkPath -File -Recurse | % { 
	$file = $_.FullName
	$hash = md5($file)
	Add-Content $currSnapPath "$file|$hash"
}

if (!(Test-Path $prevSnapPath)) {
	outputResult("Initial snapshot created. No previous snapshot to compare.")
}

# Compare
$previousSnapshot = Import-Csv $prevSnapPath  -delimiter '|'
$currentSnapshot = Import-Csv $currSnapPath -delimiter '|'

if($currentSnapshot -eq $null) {
	outputResult("No files currently in the checked directory.")
}
if($previousSnapshot -eq $null) {
	outputResult("Current snapshot created. No files in the previous snapshot to compare.  Files have been added since the last check.  Directory was previously empty.")
}

$comparison = Compare-Object $previousSnapshot $currentSnapshot -Property File,Hash | Group-Object -Property File |  % { 
	$status = "Modified"
	if($_.group.Count -eq 1 -and $_.group[0].SideIndicator -eq "=>") { $status = "Added" }
	if($_.group.Count -eq 1 -and $_.group[0].SideIndicator -eq "<=") { $status = "Deleted" }
	New-Object -TypeName psobject -Property @{ File=$_.name;Status = $status }
}

# result
if(($comparison | measure).Count -eq 0) {
	outputResult("No changes since last CheckDirectory run.")
}

$formatted = $comparison | Sort-Object File,Status | Format-Table -Wrap -AutoSize
outputResult($formatted)
