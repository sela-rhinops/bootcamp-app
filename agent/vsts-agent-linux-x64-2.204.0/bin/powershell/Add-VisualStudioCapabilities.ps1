[CmdletBinding()]
param()

function Add-TestCapability {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        $ShellPath,

        [Parameter(Mandatory = $true)]
        [ref]$Value)

    $directory = [System.IO.Path]::Combine($ShellPath, 'Common7\IDE\CommonExtensions\Microsoft\TestWindow')
    if (!(Test-Container -LiteralPath $directory)) {
        return
    }

    [string]$file = [System.IO.Path]::Combine($directory, 'vstest.console.exe')
    if (!(Test-Leaf -LiteralPath $file)) {
        return
    }

    Write-Capability -Name $Name -Value $directory
    $Value.Value = $directory
}

function Get-VSCapabilities {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet(15, 16, 17)]
        [int]$MajorVersion,

        [Parameter(Mandatory = $true)]
        [string]$keyName
    )
    $vs = Get-VisualStudio -MajorVersion $MajorVersion
    if ($vs -and $vs.installationPath) {
        # Add VisualStudio_$($MajorVersion).0.
        # End with "\" for consistency with old ShellFolder values.
        $shellFolder = $vs.installationPath.TrimEnd('\'[0]) + "\"
        Write-Capability -Name "VisualStudio_$($MajorVersion).0" -Value $shellFolder
        $latestVS = $shellFolder
        # Add VisualStudio_IDE_$($MajorVersion).0.
        # End with "\" for consistency with old InstallDir values.
        $installDir = ([System.IO.Path]::Combine($shellFolder, 'Common7', 'IDE')) + '\'
        if ((Test-Container -LiteralPath $installDir)) {
            Write-Capability -Name "VisualStudio_IDE_$($MajorVersion).0" -Value $installDir
            $latestIde = $installDir
        }
    
        # Add VSTest_$($MajorVersion).0.
        $testWindowDir = [System.IO.Path]::Combine($installDir, 'CommonExtensions\Microsoft\TestWindow')
        $vstestConsole = [System.IO.Path]::Combine($testWindowDir, 'vstest.console.exe')
        if ((Test-Leaf -LiteralPath $vstestConsole)) {
            Write-Capability -Name "VSTest_$($MajorVersion).0" -Value $testWindowDir
            $latestTest = $testWindowDir
        }
    }
    else {
        if ((Add-CapabilityFromRegistry -Name "VisualStudio_$($MajorVersion).0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName -ValueName 'ShellFolder' -Value ([ref]$latestVS))) {
            $null = Add-CapabilityFromRegistry -Name "VisualStudio_IDE_$($MajorVersion).0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName -ValueName 'InstallDir' -Value ([ref]$latestIde)
            Add-TestCapability -Name "VSTest_$($MajorVersion).0" -ShellPath $latestVS -Value ([ref]$latestTest)
        }
    }

    if ($latestVS) {
        Write-Capability -Name 'VisualStudio' -Value $latestVS
    }

    if ($latestIde) {
        Write-Capability -Name 'VisualStudio_IDE' -Value $latestIde
    }

    if ($latestTest) {
        Write-Capability -Name 'VSTest' -Value $latestTest
    }
}

# Define the key names.
$keyName10 = 'Software\Microsoft\VisualStudio\10.0'
$keyName11 = 'Software\Microsoft\VisualStudio\11.0'
$keyName12 = 'Software\Microsoft\VisualStudio\12.0'
$keyName14 = 'Software\Microsoft\VisualStudio\14.0'
$keyName15 = 'Software\Microsoft\VisualStudio\15.0'
$keyName16 = 'Software\Microsoft\VisualStudio\16.0'
$keyName17 = 'Software\Microsoft\VisualStudio\17.0'

# Add the capabilities.
$latestVS = $null
$latestIde = $null
$latestTest = $null
$null = Add-CapabilityFromRegistry -Name 'VisualStudio_10.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName10 -ValueName 'ShellFolder' -Value ([ref]$latestVS)
$null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_10.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName10 -ValueName 'InstallDir' -Value ([ref]$latestIde)
$null = Add-CapabilityFromRegistry -Name 'VisualStudio_11.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName11 -ValueName 'ShellFolder' -Value ([ref]$latestVS)
$null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_11.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName11 -ValueName 'InstallDir' -Value ([ref]$latestIde)
if ((Add-CapabilityFromRegistry -Name 'VisualStudio_12.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName12 -ValueName 'ShellFolder' -Value ([ref]$latestVS))) {
    $null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_12.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName12 -ValueName 'InstallDir' -Value ([ref]$latestIde)
    Add-TestCapability -Name 'VSTest_12.0' -ShellPath $latestVS -Value ([ref]$latestTest)
}

if ((Add-CapabilityFromRegistry -Name 'VisualStudio_14.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName14 -ValueName 'ShellFolder' -Value ([ref]$latestVS))) {
    $null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_14.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName14 -ValueName 'InstallDir' -Value ([ref]$latestIde)
    Add-TestCapability -Name 'VSTest_14.0' -ShellPath $latestVS -Value ([ref]$latestTest)
}

Get-VSCapabilities -MajorVersion 15 -keyName $keyName15

Get-VSCapabilities -MajorVersion 16 -keyName $keyName16

Get-VSCapabilities -MajorVersion 17 -keyName $keyName17

# SIG # Begin signature block
# MIIntgYJKoZIhvcNAQcCoIInpzCCJ6MCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAwgL9Nmnw0Xxol
# FSNRX7258ys82s8L5VByx9V5xTx77qCCDYEwggX/MIID56ADAgECAhMzAAACUosz
# qviV8znbAAAAAAJSMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjEwOTAyMTgzMjU5WhcNMjIwOTAxMTgzMjU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDQ5M+Ps/X7BNuv5B/0I6uoDwj0NJOo1KrVQqO7ggRXccklyTrWL4xMShjIou2I
# sbYnF67wXzVAq5Om4oe+LfzSDOzjcb6ms00gBo0OQaqwQ1BijyJ7NvDf80I1fW9O
# L76Kt0Wpc2zrGhzcHdb7upPrvxvSNNUvxK3sgw7YTt31410vpEp8yfBEl/hd8ZzA
# v47DCgJ5j1zm295s1RVZHNp6MoiQFVOECm4AwK2l28i+YER1JO4IplTH44uvzX9o
# RnJHaMvWzZEpozPy4jNO2DDqbcNs4zh7AWMhE1PWFVA+CHI/En5nASvCvLmuR/t8
# q4bc8XR8QIZJQSp+2U6m2ldNAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUNZJaEUGL2Guwt7ZOAu4efEYXedEw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDY3NTk3MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAFkk3
# uSxkTEBh1NtAl7BivIEsAWdgX1qZ+EdZMYbQKasY6IhSLXRMxF1B3OKdR9K/kccp
# kvNcGl8D7YyYS4mhCUMBR+VLrg3f8PUj38A9V5aiY2/Jok7WZFOAmjPRNNGnyeg7
# l0lTiThFqE+2aOs6+heegqAdelGgNJKRHLWRuhGKuLIw5lkgx9Ky+QvZrn/Ddi8u
# TIgWKp+MGG8xY6PBvvjgt9jQShlnPrZ3UY8Bvwy6rynhXBaV0V0TTL0gEx7eh/K1
# o8Miaru6s/7FyqOLeUS4vTHh9TgBL5DtxCYurXbSBVtL1Fj44+Od/6cmC9mmvrti
# yG709Y3Rd3YdJj2f3GJq7Y7KdWq0QYhatKhBeg4fxjhg0yut2g6aM1mxjNPrE48z
# 6HWCNGu9gMK5ZudldRw4a45Z06Aoktof0CqOyTErvq0YjoE4Xpa0+87T/PVUXNqf
# 7Y+qSU7+9LtLQuMYR4w3cSPjuNusvLf9gBnch5RqM7kaDtYWDgLyB42EfsxeMqwK
# WwA+TVi0HrWRqfSx2olbE56hJcEkMjOSKz3sRuupFCX3UroyYf52L+2iVTrda8XW
# esPG62Mnn3T8AuLfzeJFuAbfOSERx7IFZO92UPoXE1uEjL5skl1yTZB3MubgOA4F
# 8KoRNhviFAEST+nG8c8uIsbZeb08SeYQMqjVEmkwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZizCCGYcCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAlKLM6r4lfM52wAAAAACUjAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgIkfnS3ur
# WsJlmaR7Pk+sARq7eUGlggHBxPWcHMNmbOIwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQAILEdVmekXoET6iB6O98Q7kGH2xyND/h9R6cj8BoHA
# ZDbpb0BL2FSfVc6P6Q7Yd44OwOpQbm5W9inB8ta0qENokJ9EAFZ0/Ve0iZOlFSUM
# NJ2pFb18FzUtnYzaohx0aWw4wbC7yFFhHAqKNxVSUQuFRZAptxnGmGj7GspyPnaI
# Wiew57q0R+kWArLmAzUClrDreyKaKq3jPgolPnxl31xaKFrHtF/qYxDTCJ0krqWI
# r/N6mVNvDVoMES6i9eJPeC1prdwikEQKWFrXrYhaC4nVfSvMCcAseRTVnqOr6Dzr
# EDq7+sgscleq36G2VtEGQv0AGeiym7zW1hHGX6B7v/SEoYIXFTCCFxEGCisGAQQB
# gjcDAwExghcBMIIW/QYJKoZIhvcNAQcCoIIW7jCCFuoCAQMxDzANBglghkgBZQME
# AgEFADCCAVgGCyqGSIb3DQEJEAEEoIIBRwSCAUMwggE/AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIA+9J0exL795tV7Zu2cqQZYgsHXHqx6aX+uE4Tg/
# h19DAgZibEVhb/EYEjIwMjIwNTA1MDczMjAyLjI3WjAEgAIB9KCB2KSB1TCB0jEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWlj
# cm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFs
# ZXMgVFNTIEVTTjowODQyLTRCRTYtQzI5QTElMCMGA1UEAxMcTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgU2VydmljZaCCEWUwggcUMIIE/KADAgECAhMzAAABh0IWZgRc8/SN
# AAEAAAGHMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
# MDEwMB4XDTIxMTAyODE5MjczOVoXDTIzMDEyNjE5MjczOVowgdIxCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJ
# cmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBF
# U046MDg0Mi00QkU2LUMyOUExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFNlcnZpY2UwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC+aXgZYz0D
# o9ERCIeBkAA8rqf5OHqb4tjApgtpAWVldtOquh2GyeLsdUhGSoEW4byiDUpmvLTb
# ESaZt2nz07jTEIhB9bwUpbug7+Vhi1QBBbaSnS4y5gQnVeRnp4eNwy6oQnALjtRq
# RnHcB6RqQ/4Z8a4MM72RkZBF7wimKInhCSfqZsOFtGmBxQ52wPOY3PqRcbuB8h+B
# yzmTO4og/qc3i2yM+HIXnxVTRl8jQ9IL6fk5fSGxTyF5Z7elSIOvmCo/XprqQiMU
# keSA09iAyK8ZNApyM3E1xeefKZP8lW42ztm+TU/kpZ/wbVcb8y1lnn+O6qyDRChS
# ZBmNWHRdGS7tikymS1btd8UDfL5gk4bWlXOLMHc/MldQLwxrwBTLC1S5QtaNhPnL
# v8TDAdaafVFPQ+Fin2Sal9Lochh8QFuhhS9QtbYecY1/Hrl/hSRzuSA1JBt4AfrK
# M7l2DoxTA9/Oj+sF01pl8nFntGxxMHJO2XFuV9RPjrI8cJcAKJf8GFocRjh50WCn
# 9whvtccUlu7iY0MA/NGUCQiPVIa470bixuSMz1ek0xaCWPZ0L1As3/SB4EVeg0jw
# X4d8fDgmj6nqJI/yGfjeaSRYpIY6JPiEsnOhwSsWe0rmL095tdKrYG8yDNVz4EG8
# I3fkN8PSaiRErFqba1AzTrRI5HLdLu5x6wIDAQABo4IBNjCCATIwHQYDVR0OBBYE
# FCJRwBa6QS1hgX7dYXOZkD8NpY0gMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMF8GA1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEw
# KDEpLmNybDBsBggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFt
# cCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYI
# KwYBBQUHAwgwDQYJKoZIhvcNAQELBQADggIBALmrflPZEqMAVE3/dxiOc8XO09rs
# p6okomcqC+JSP0gx8Lz8VDajHpTDJ3jRNLvMq+24yXXUUWV9aQSdw3eWqKGJICog
# M851W+vWgljg0VAE4fMul616kecyDRQvZRcfO+MqDbhU4jNvR210/r35AjLtIOlx
# WH0ojQRcobZuiWkHKmpG20ZMN3QlCQ60x2JKloOk4fCAIw1cTzEi7jyGK5PTvmgi
# qccmFrfvz8Om6AjQNmNhxkfVwbzgnTq5yrnKCuh32zOvX05sJkl0kunK8lYLLw9E
# MCRGM8mCVKZ+fZRHQq+ejII7OOzMDA0Kn8kmeRGnbTB4i3Ob3uI2D4VkXUn0TXp5
# YgHWwKvtWP1APoq37PzWs5wtF/GGU7b+wrT1TD4OJCQ9u7o5ndOwO8uyvzIb1bYD
# zJdyCA2p3heku10SR/nY4g3QaBEtJjUs0MHggpj5mPfgjAxsNuzawKKDkuLYgtYQ
# xX/qDIvfsnvU1tbtXOjt9was2d706rGAULZZfl16DHIndLHZsrDqVt/TgppedME5
# LPRAL5F8m7Pyc6kh/bz5aYw+JxfaXuCz8ysLlqebIr+dt4qRo7H4BeHBgvMRM2D7
# UhzKCN3CdupYpp8t0I0p+Gxv+AzlIVuAPkBMRfVsDHBQVXEq9C/R0hECbloOMXcN
# mmC/LeZKiNKsE3/zMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTAN
# BgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9y
# aXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBAOThpkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDi
# vbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZnhUYjDLWNE893MsAQGOhgfWpSg0S3po5G
# awcU88V29YZQ3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJprx2rrPY2vjUm
# ZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxqD89d9P6OU8/W7IVWTe/dvI2k45GPsjks
# UZzpcGkNyjYtcI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka97aSueik3rMvr
# g0XnRm7KMtXAhjBcTyziYrLNueKNiOSWrAFKu75xqRdbZ2De+JKRHh09/SDPc31B
# mkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9ituqBJR6L8FA6PR
# c6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1DTsEzOUyOArxCaC4Q6oRR
# RuLRvWoYWmEBc8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItboKaDIV1fMHSR
# lJTYuVD5C4lh8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqvUAV6bMURHXLvjflS
# xIUXk8A8FdsaN8cIFRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6tAgMBAAGjggHd
# MIIB2TASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSa
# voKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYD
# VR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjR
# PZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNy
# bDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0G
# CSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5HZHix
# BpOXPTEztTnXwnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjY
# Ni6cqYJWAAOwBb6J6Gngugnue99qb74py27YP0h1AdkY3m2CDPVtI1TkeFN1JFe5
# 3Z/zjj3G82jfZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis9/kpicO8F7BU
# hUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbCHcNhcy4sa3tuPywJeBTpkbKpW99Jo3QM
# vOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0sHrYUP4KWN1A
# PMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNtyo4JvbMBV0lUZNlz138eW0QBjloZkWsN
# n6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJsWkBRH58oWFs
# c/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue1
# 0CgaiQuPNtq6TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6g
# MTN9vMvpe784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm
# 8qGCAtQwggI9AgEBMIIBAKGB2KSB1TCB0jELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0
# aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjowODQyLTRCRTYt
# QzI5QTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEB
# MAcGBSsOAwIaAxUAeHeTVAQoBkSGwsZgYe1//oMbg/OggYMwgYCkfjB8MQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIFAOYdWycwIhgP
# MjAyMjA1MDUwNDA1NTlaGA8yMDIyMDUwNjA0MDU1OVowdDA6BgorBgEEAYRZCgQB
# MSwwKjAKAgUA5h1bJwIBADAHAgEAAgIgVTAHAgEAAgIRrzAKAgUA5h6spwIBADA2
# BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIB
# AAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBABLrT4evkrlIPdpQtMbWilIlOkqd3dvy
# zBDuFg04vEMzG6yw+W0Nj6v/Nf3MGge9Lykr7c8CYCp+jHz0adi8a1ptyt2CC2Du
# a/pZhlt6N2MpmQ0bRfE+Udb9cm9EyK4vsx6XBysmmnrdk8MhpvyYZyPilOA0x9w0
# Cy75vNnpeB7xMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAGHQhZmBFzz9I0AAQAAAYcwDQYJYIZIAWUDBAIBBQCgggFKMBoG
# CSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgocypLP0Y
# Du+Uv8jISIpUW2IBfon4sARCKYnNRD2y5eQwgfoGCyqGSIb3DQEJEAIvMYHqMIHn
# MIHkMIG9BCDELPCgE26gH3bCwLZLFmHPgdUbK8JmfBg25zOkbJqbWDCBmDCBgKR+
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABh0IWZgRc8/SNAAEA
# AAGHMCIEIJLRhaZsOfBnMycqv7oYA3ZdcIvORlSArcZm1o47imm8MA0GCSqGSIb3
# DQEBCwUABIICAA/BZNFSsn5NsNb5upEGtIRC14W72lB6epEUJr+tv+QQqHJYhRru
# N4gPGsrsGFkUFupg+WVQS2KgjQ/STqmCaP4bj2D/0FPsfefv64+4af0bOXERUX+K
# eO5l/w2s8Rl6jBMMKeuNTQAyRXT6rSOkt03lZ//VqjadJbwuIWHXMCFPtAKFG1MK
# 53Akgj3FkNW17zE8W6/nOqkhr+9dtrXoEbdMrTg7uq4w//9ns4eBTPjdq7bCxsA2
# cQSZmqpG2YTSZXDSgYIdDrQ1KqDZqp8LL1VeNzoH9vpEXMWYgN7YEp3QeoYN9BLM
# FCJEIWjPTbILMyZbjMY9iXquyfHYcSMqVm9HEGEG91mHP9Vw2OhpmNZEtpXzaOLx
# ze4HA6Cc6v0BCzYJPnISPpaxtaueTzs4Xe/ROQKKK2K61GVQLRLH3sLfdZJ4DW27
# lHC4SW47MGUQEj4T8joparpkuefg6+k3+uijAtOwGptKyCplcAEZ43Kiua+oR454
# RSleMXCaBDZ+te2JEf7iRDUGsmTG0AKKfTgDk3x2OHU+kwJbP4A1QZnKeohlumWh
# z45yKCP0y31VvLMzT5m+54VSGw2tnUmqX1vpm//yjGvJVGQJDm9KViSnNjKoWRUE
# hlBSQuDfJEdC58HRe0/2FY2zJka0EXULQrRI8tX5UvwQDxEWct+Bph43
# SIG # End signature block
