<#
.Synopsis
   Outputs the Windows Update setting on a computer.
.DESCRIPTION
   Takes a string array of computer names and outputs 
   the computer's Windows Update setting.
.EXAMPLE
   Get-WindowsUpdateSetting $ComputerNames
.EXAMPLE
   $ComputerNames | Get-WindowsUpdateSetting
#>
Function Get-WindowsUpdateSetting
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$ComputerNames
    )

    Process
    {
        Foreach ($ComputerName in $ComputerNames)
        {
            Try
            {
                $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)
                $RegistryKey= $Registry.OpenSubKey('SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update')
                $AUOptions = $RegistryKey.GetValue('AUOptions')

                If ($AUOptions -eq '1')
                {
                    $UpdateSetting = 'Never check for updates (not recommended)'
                }
                ElseIf ($AUOptions -eq '2')
                {
                    $UpdateSetting = 'Check for updates but let me choose whether to download and install them'
                }
                ElseIf ($AUOptions -eq '3')
                {
                    $UpdateSetting = 'Download updates but let me choose whether to install them'
                }
                ElseIf ($AUOptions -eq '4')
                {
                    $UpdateSetting = 'Install updates automatically (recommended)'
                }
                Else
                {
                    $UpdateSetting = "Unknown Windows Update setting"
                }

            }
            Catch
            {
                $UpdateSetting = "Unable to connect to system's registry"
            }

            [psobject]$System = @{
                'Name' = $ComputerName;
                'UpdateSetting' = $UpdateSetting
                }

            $System
        }
    }
}