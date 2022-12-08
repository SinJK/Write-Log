
class MessageLog {
    [datetime]$date
    [string] $category
    [string] $message
} 

function ConvertFrom-Log {
    param(
        [Parameter(Mandatory = $true)]
        [Alias("Path")]
        [ValidateScript({ Test-Path $_ })]
        [string]
        $FilePath,
        [Parameter(Mandatory = $false, HelpMessage = "Accepted: , ;")]
        [string]
        $Delimiter = ";"
    )

    $arrLog = @()

    $pattern = "(?<test>^\d{1,4}\-\d{1,2}\-\d{1,2})"
    foreach ($line in (get-content -Path $FilePath | Select-String -Pattern "^\d{1,4}\-\d{1,2}\-\d{1,2}")) {
        #if ($line -match $pattern) {
            $NewMessage = New-Object –TypeName MessageLog
            $NewMessage.date = ($line -split ";")[0]
            $NewMessage.Category = ($line -split ";")[1]
            $NewMessage.Message = ($line -split ";")[2]
            <#
            $custom = [PSCustomObject]@{
                Date     = ($line -split ";")[0]
                Category = ($line -split ";")[1]
                Message  = ($line -split ";")[2]
            }
            #>
            $arrLog += $NewMessage

        #}
    }

    $arrLog
}


[Enum]::GetValues([System.Management.Automation.ActionPreference])