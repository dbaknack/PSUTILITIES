Function Platform {
    $platform = @{
        onMac = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)
        onLinux = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)
        onWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
    }
    foreach($os in $platform.keys){
        $myOS = [string]
        $osFound = [bool]
        if($platform.$os){
            $osFound = $true
            $myOS =$os
            break
        }else{
            $osFound = $false
        }
    }
    if($osFound){
        $myOS
    }
}

Function PlatformParameters{
    $myPlatform = Platform
    $osParameters = @{
        Separator   = [string]
        OS          = $myPlatform
    }
    switch($myPlatform){
        "onMac"{
            $osParameters.Separator = '/'
        }
        "onLinux"{
            $osParameters.Separator = '/'
        }
        "onWindows"{
            $osParameters.Separator = '\'
        }
    }
    $osParameters
}

Function JsonConverter{
    $myLocation         = Get-Location
    $functionPath       = $myLocation.Path
    $PlatformParameters = PlatformParameters
    $Seperator          = $PlatformParameters.Separator
    $classPath          = "{1}{0}{2}" -f $Seperator, $functionPath, "Classes.ps1"
    
    $JSONConverter = [JsonConverter]::new()
    $JSONConverter
}

Function PSUTILITIES {
    $PSUTILITIES =  [PSUTILITIES]::new()
    $PSUTILITIES
}

