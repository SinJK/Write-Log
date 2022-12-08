function Write-Log {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [Alias("Path")]
        [string]
        $FilePath,

        [Parameter(Mandatory = $false, ParameterSetName = "std")]
        [ValidateSet("Information", "Warning", "Error")]
        [string]
        $Category,

        [Parameter(Mandatory = $false, HelpMessage = "Accepted: , ;", ParameterSetName = "std")]
        [ValidateSet(",", ";")]
        [string]
        $Delimiter = ";",

        [Parameter(Mandatory = $true, ParameterSetName = "std", ValueFromPipeline = $true)]
        [string]
        $Message,

        [Parameter(Mandatory = $false)]
        [switch]
        $Toscreen,

        [Parameter(Mandatory = $false, ParameterSetName = "h")]
        [switch]
        $Header,

        [Parameter(Mandatory = $false, HelpMessage = "Accepted: TXT or LOG")]
        [ValidateSet("log", "txt")]
        $encoding = "log",

        [Parameter(Mandatory = $false, ParameterSetName = "f")]
        [switch]
        $Footer
    )

    Begin {         
        if ($encoding) {
            $FilePath = $filepath -replace $filepath.split(".")[-1], $encoding

        }
        if ($PSCmdlet.ShouldProcess($FilePath, "Logging")) {
        }
        if ($header) {

            $osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption
            $osArch = (Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture
            $head = @"
+----------------------------------------------------------------------------------------+
Script fullname          : $($PSScriptRoot.FullName)
When generated           : $(Get-Date -f "yyyy-dd-MM hh:mm:ss")
Current user             : $env:computername\$env:username
Current computer         : $env:computername
Operating System         : $osVersion
OS Architecture          : $osArch
+----------------------------------------------------------------------------------------+
"@
            if ($Toscreen) { write-host $head }
            $output = $head | out-file $FilePath
        }
    }

    Process {
        
        $date = $(Get-Date -f "yyyy-dd-MM hh:mm:ss")
        if ($category -match "Information") {
            if ($Toscreen) {
                Write-host -ForegroundColor Cyan "$date$delimiter INF; $Message"
            }
            "$date$delimiter INF; $Message" | out-file $FilePath -Append
        }
        if ($category -match "Warning") {
            if ($Toscreen) {
                Write-host -ForegroundColor Yellow  "$date$delimiter WAR; $Message"
            }
            "$date$delimiter WAR; $Message" | out-file $FilePath -Append
        }
        if ($category -match "Error") {
            if ($Toscreen) {
                Write-host -ForegroundColor Red  "$date$delimiter ERR; $Message"
            }
            "$date$delimiter ERR; $Message" | out-file $FilePath -Append
        }
            
    }

    End {
        if ($footer) {

            $osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Name
            $osArch = (Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture
            $startime = get-item -Path $FilePath | Select-Object CreationTIme
            $endtime = [datetime]::Now
            $endexecution = New-TimeSpan -End $endtime -Start $startime.CreationTime    
            $foot = @"
+----------------------------------------------------------------------------------------+  
End Time           : $(Get-Date -f "yyyy-dd-MM hh:mm:ss")
Total duration (seconds) : $($endexecution.Seconds)
Total duration (minutes) : $($endexecution.Minutes)
+----------------------------------------------------------------------------------------+
"@
            if ($Toscreen) { write-host $foot }
            $foot | out-file -FilePath $FilePath -Append | Out-Null
        }
    }
}


