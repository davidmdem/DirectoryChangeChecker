DirectoryChangeChecker
======================

A PowerShell script that creates a report indicating what files in a specified directory have changed since the last time the script was run.

A snapshot of filenames and MD5 hashes will be taken of this directory and stored in a \results folder next to the CheckDirectory.ps1 file.

Two snapshots are maintained at a time - a current snapshot that is taken at execution time and the previous snapshot for comparison.

##Requirements
Currently PowerShell 3.0 is required as 2.0 does not have the -File parameter for Get-ChildItem.  To convert, you can remove that param and filter out directories from the results.

##Usage
The script accepts the directory to check as its first parameter.

```
.\CheckDirectory.ps1 "C:\test"
``` 

##Output
A \results folder is created next to CheckDirectory.ps1.  Inside of \results, another folder is created to hold the check results for whatever directory you are checking.

For example:
```
.\CheckDirectory.ps1 "C:\test"
.\CheckDirectory.ps1 "C:\data"
``` 

Will produce a result directory structure:

\results<br>
&nbsp;&nbsp;&nbsp;&nbsp;\C-test <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;!current snapshot.csv<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;!previous snapshot.csv<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[timestamp].txt<br>
&nbsp;&nbsp;&nbsp;&nbsp;\C-data<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;!current snapshot.csv<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;!previous snapshot.csv<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[timestamp].txt

##Scheduling
Using the Windows Task Scheduler.

Action: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
Arguments: "C:\[path]\CheckDirectory.ps1 'C:\test'"

Note: how the directory being checked is in single qutoes.

Note: The initial run will only produce a first snapshot.  It will not have anything to compare.  It is advisable to run CheckDirectory once before scheduling.

If scheduled weekly, your results txt file will contain all directory changes that have occured in the last week.  If scheduled hourly it will contain changes made in the last hour.
