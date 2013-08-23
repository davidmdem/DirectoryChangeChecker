# Slightly modified from @davor's comment in 
# http://stackoverflow.com/questions/10521061/how-to-get-a-md5-checksum-in-powershell
function md5($file) {
	$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	[System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::Open("$file",[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)))
}

# Removes trailing slash from a string
function chopSlash($string) {
	if($string.substring($string.length - 1, 1) -eq "\") {
		return $string -replace ".$"
	} else {
		return $string
	}
}

function addSlash($string) {
	if($string.substring($string.length - 1, 1) -eq "\") {
		return $string
	} else {	
		return $string + "\"
	}
}

# Puts output to a file and exits.
function outputResult($result) {
	if($resultFilePath -eq $null) {
		echo $result
	} else {
		$result | Out-File $resultFilePath	
	}	
	Exit
}
