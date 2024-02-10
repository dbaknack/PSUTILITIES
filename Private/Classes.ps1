class JsonConverter {
    [object]ConvertFromJson([object]$Object) {
        if ($Object -is [System.Management.Automation.PSCustomObject]) {
            $hashTable = @{}
            foreach ($property in $Object.PSObject.Properties) {
                $hashTable[$property.Name] = $this.ConvertFromJson($property.Value)
            }
            return $hashTable
        }
        elseif ($Object -is [System.Collections.ArrayList]) {
            return $Object.ForEach({ $this.ConvertFromJson($property.Value)})
        }
        elseif ($Object -is [System.Collections.Generic.Dictionary[string, object]]) {
            $hashTable = @{}
            foreach ($entry in $Object) {
                $key = $entry.Key
                $value = $this.ConvertFromJson($Object.Value)
                $hashTable[$key] = $value
            }
            return $hashTable
        }
        else {
            return $Object
        }
    }
}

class PSUTILITIES {
    <#  Description -------------------------------------------------------
            This class parameter acts as a table for internal utilities.
            You may add more to the table as needed.
    #>
    $INPUT_METHOD_PARAMS_TABLE = @{
        GetMethodParamstable        = @("MethodName")
        AddUtilitySettings          = @("Settings","Label")
        AddMethodParamstable        = @("MethodName","KeysList")
        CreateItem                  = @("ItemType","Path")
        InputKeysValidation         = @("MethodName","UserInputHashtable")
        DisplayMessage              = @("Type","Category","Message")
        UpdateUtilitySettings       = @("Label","UtilityParamsTable")
        GetUtilitySettingsTable     = @("Label")
        GetUtilityMethodList        = @("GetAllMyUtilities")
        CreateCache                 = @("Label","FolderPath","FileName")
        CacheConfiguration          = @("Label","FolderPath","FileName","Configuration","Overwrite")
        ReadCache                   = @("Label")
        RemoveCache                 = @("Label")
    }
    <#  Description -------------------------------------------------------
            This class parameter is how you control some of the itilities
            defined in the class.
    #>
    $UtilitySettings = @{
        DisplayMessage = @{
            DebugOn     = $true
            Feedback    = $true
            Mute        = $false
        }
    }
    [psobject]GetExamples([string]$MethodName){
        $exampleTable = @{
            CreateItem = '
            # Usage Decription:
            #   -   CreateItem      Use this when you need to create a folder or file.
            #
            # --------------------------------------------------------------------------------------------------------
            # Parameter Description:
            #   -   ItemPath:       Can either be "Directory" or "File".
            #   -   Path:           When ItemPath is "Directory", do not use a trailing "{0}". Can be either
                                    a dynamic or full path.
                                    When ItemPath is "File", either dynamic or a full path, include the file extension.
            #
            # --------------------------------------------------------------------------------------------------------
            # Example:
                CreateItem(
                    ItemPath        = "Directory"
                    Path            = ".{0}FolderName"
                )' -f (PlatformParameters).Separator
        }
        return $exampleTable.$MethodName
    }
    [void]AddMethodParamstable([hashtable]$fromSender){
        <#
            #example usage:
            $methodParams = @{
                MethodName = 'TestItemExists'
                KeysList = @('key1','key2')
            }
            $UTILITY.AddMethodParamstable($methodParams)
        #>
        # all methods define there method name
        $METHOD_NAME        = "AddMethodParamstable"
        $validationParams = @{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        }
        $this.InputKeysValidation($validationParams)

        # if hashtable is valid, the method name from sender is used to retried the values requested
        $getMethodParams = @{
            MethodName = $fromSender.MethodName
        }
        if(($this.GetMethodParamstable($getMethodParams))-ne 0){
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"Method '$($fromSender.MethodName)' already exists in INPUT_METHOD_PARAMS_TABLE."
            Write-Error -Message $msgError ; $Error[0]
            return
        }

        [string]$myMethodName   = $fromSender.MethodName
        [array]$myKeysList      = $fromSender.KeysList
        $this.INPUT_METHOD_PARAMS_TABLE += @{$myMethodName = $myKeysList}
    }
    [psobject]GetMethodParamstable([hashtable]$fromSender){
        <#
            #example usage
            $getMethodParams = @{
                MethodName = 'AddMethodParamstable'
            }
            $UTILITY.GetMethodParamstable($getMethodParams)
        #>
        # all methods define there method name
        $METHOD_NAME                = "GetMethodParamstable"

        # the validation params are defined, making sure the user inputs the correct properties
        $validationParams = @{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        }

        #$exitConditionMet   = $false
        $methodParamsExists = $true
        # if hashtable is valid the methodname from sender is used to retriev the values requested
        $myMethodName   = $fromSender.MethodName
        $myMethodParams = $this.INPUT_METHOD_PARAMS_TABLE.$myMethodName

        if($null -eq $myMethodParams){
            $methodParamsExists = $false
        }

        if($methodParamsExists -eq $false){
            return 0
        }
        return $myMethodParams
    }
    [void]InputKeysValidation([hashtable]$fromSender){
        <#  Instructions -------------------------------------------------------
            Step 1:
                In order to validate the hashtable you are using as input for a
                given method; you'll need to define the method name, and the 
                hashtable keys.

                AddMethodParamstable(@{
                    MethodName  = 'MyMethodName'
                    KeysList    = @('key1','key2')
                })

            Step 2:
                Within the method you intend to use this method in, you need to
                invoke this method in the following way.

                $UTILITY.InputKeysValidation(@{
                    MethodName          = 'MyMethodName'
                    UserInputHashtable  = $myHashtable
                })
        #>
        #region:    Self Validation
        <#
                Remarks ---------------------------------------------------------
                InputKeysValidation validates itself each time other things need
                to be validated. The commands defined within
                #region: Self Validation are commands applicable to
                InputKeysValidation only.
        #>
        $METHOD_NAME                = "InputKeysValidation"
        $METHOD_PARAMS_LIST         = @("MethodName","UserInputHashtable")
        [array]$USER_PARAMS_LIST    = $fromSender.Keys
        $exitConditionMet           = $false

        # guard clause: handle a null passed parameter
        if($USER_PARAMS_LIST.count -eq 0){
            $exitConditionMet = $true
        }

        if($exitConditionMet){
            $msgError = "{0}:: {1}" -f $METHOD_NAME,"Input parameter cannot be null."
            Write-Error -Message $msgError ; $Error[0]
            return
        }

        # guard clause: handle keys not defined in METHOD_PARAMAS_LIST
        $undefinedUserParamList = @()
        foreach($userParam in $USER_PARAMS_LIST){
            if($METHOD_PARAMS_LIST -notcontains $userParam){
                $undefinedUserParamList += $userParam
                $exitConditionMet = $true
            }
        }
        if($exitConditionMet){
            $undefinedUserParamList -join ', '
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"The following paramter(s) is/are not defined '$undefinedUserParamList'."
            Write-Error -Message $msgError ; $Error[0]
            return
        }

        #guard clause: the keys provided are the keys defined and no less
        $definedUserParamCount      = $METHOD_PARAMS_LIST.count
        $definedUserParamList       = @()
        $counter                    = 0
        foreach($methodParams in $METHOD_PARAMS_LIST){
            foreach($userParam in $USER_PARAMS_LIST){
                $definedUserParamList += $userParam
            }
            $counter++ 
        }
        if($counter -ne $definedUserParamCount){
            $exitConditionMet = $true
        }

        if($exitConditionMet){
            $undefinedUserParamList -join ', '
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"The following paramter(s) are missing '$definedUserParamList'."
            Write-Error -Message $msgError ; $Error[0]
            return
        }
        #endregion: Self Validation

        #   - define the method names in the class parameters for use internally in this method
        #   - define the method name to validate
        [array]$inputMethodNamesList    = $this.INPUT_METHOD_PARAMS_TABLE.keys
        [string]$inputMethodName        = $fromSender.MethodName
        
        #   - (guard_clause): check that the method name provided exists in the class properties definiton 
        $inputExitConditonMet           = $false
        if($inputMethodNamesList -notcontains $inputMethodName){
            $inputExitConditonMet = $true
        }
        if($inputExitConditonMet){
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"There is no method defined with the name of '$inputMethodName'."
            Write-Error -Message $msgError ; $Error[0]
            return
        }
        #   - (guard_clause): check tha the method name provided values count is not empty
        [array]$interalmethodParamsList = $this.INPUT_METHOD_PARAMS_TABLE.$inputMethodName
        if($interalmethodParamsList -eq 0){
            $inputExitConditonMet = $true
        }
        if($inputExitConditonMet){
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"None of the supplied keys to UserInputHashtable are defined for '$inputMethodName' in INPUT_METHOD_PARAMS_TABLE."
            Write-Error -Message $msgError ; $Error[0]
            return
        }

        #   - (guard_clause): the keys provided to this method are checked against the ones stowed in the class properties
        [array]$inputUserParamsList      = $fromSender.UserInputHashtable.keys
        $inputUndefinedUserParamList = @()
        foreach($inputUserParam in $inputUserParamsList){
            if($interalmethodParamsList -notcontains $inputUserParam){
                $inputUndefinedUserParamList += $inputUserParam
                $exitConditionMet = $true
            }
        }
        if($exitConditionMet){
            $inputUndefinedUserParamList -join ', '
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"The following paramter(s) is/are not defined in the INPUT_PARAMS_TABLE '$inputUndefinedUserParamList'."
            Write-Error -Message $msgError ; $Error[0]
            return
        }
    }
    [psobject]GetUtilityMethodList([hashtable]$fromSender){
        #region: Validation
        $METHOD_NAME        = "GetUtilityMethodList"
        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })
        #endregion: Validation
        $exitConditionMet   = $false
        $msgError           = [string]
        $inputValue = ($fromSender.GetAllMyUtilities)
        if($inputValue -eq $false){
            $exitConditionMet = $true
            
        }

        if($exitConditionMet){
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME, "Unput is only allowed to be `$true."
            Write-Error -Message $msgError
            return $Error[0]
        }

        [array]$myMethodList = $this.INPUT_METHOD_PARAMS_TABLE.keys
        return $myMethodList
    }
    [void]CreateItem([hashtable]$fromSender){
        # all methods define there method name
        $METHOD_NAME        = "CreateItem"
        $exitConditionMet   = $false

        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })

        [string]$path       = $fromSender.Path
        [string]$itemType   = $fromSender.ItemType
        $Platform  = PlatformParameters
        if($Platform.OS -eq 'OnWindows'){
            $charList = $path.ToCharArray()
            if($charList -contains '/'){
                $path = $path -replace '/',$Platform.Separator
            }
        }
        if($Platform.OS -eq 'onMac'){
            $charList = $path.ToCharArray()
            if($charList -contains '\'){
                $path = $path -replace '\',$Platform.Separator
            }
        }
        if($Platform.OS -eq 'onLinux'){
            $charList = $path.ToCharArray()
            if($charList -contains '\'){
                $path = $path -replace '\',$Platform.Separator
            }
        }
        
        if($itemType -match "Folder"){
            $itemType = "Directory"
        }

        $itemExists = $false
        if(-not(Test-Path -Path $path)){
            try{
                $exitConditionMet = $false
                New-Item -Path $path -ItemType $itemType | Out-Null
            }catch{
                $exitConditionMet = $true
            }

            if($exitConditionMet){
                $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"'$($fromSender.ItemType)' - '$($fromSender.Path)' was not able to be created"
                Write-Error -Message $msgError; $Error[0]
                return 
            }
            $this.DisplayMessage(@{
                Message 	= ("[{0}]:: {1}" -f $METHOD_NAME,"'$($fromSender.ItemType)' - '$($fromSender.Path)' created.")
                Type 		= "debug"
                Category 	= "debug"
            })
        }else{
            $itemExists = $true
        }

        if($itemExists){
            $this.DisplayMessage(@{
                Message 	= ("[{0}]:: {1}" -f $METHOD_NAME,"'$($fromSender.ItemType)' - '$($fromSender.Path)' item already exists.")
                Type 		= "debug"
                Category 	= "debug"
            })
        }
    }
    [psobject]GetUtilitySettingsTable([hashtable]$fromSender){
        <#
            # example usage
            $util.GetUtilitySettingsTable(@{Label = 'DisplayMessage'})
        #>

        # all methods define there method name
        $METHOD_NAME            = "GetUtilitySettingsTable"
        $utilitySettingsExists  = [bool]
        # the validation params are defined, making sure the user inputs the correct properties
        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })
        # if hashtable is valid the methodname from sender is used to retried the values requested
        $myLabel            = $fromSender.Label
        $myUtilitySettings  = $this.UtilitySettings.$myLabel

        if($null -eq $myUtilitySettings){
            $utilitySettingsExists = $false
        }

        if($utilitySettingsExists -eq $false){
            return 0
        }
        return $myUtilitySettings
    }
    [void]UpdateUtilitySettings([hashtable]$fromSender){
        <#
            #example usage:
            $utilitySettingsParams = @{
                Label = 'DisplayMessage'
                UtilityParamsTable = @{
                    DebugOn     = $true
                    Feedback    = $true
                    Mute        = $false
                }
            }
            $util.UpdateUtilitySettings($utilitySettingsParams)
        #>
        # all methods define there method name
        $METHOD_NAME        = "UpdateUtilitySettings"
        $exitConditionMet   = $false
        # the validation params are defined, making sure the user inputs the correct properties
        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })

        [string]$myLabel = $fromSender.Label
        $myUtilityParams = $this.GetUtilitySettingsTable(@{Label = $myLabel})

        if(0 -eq $myUtilityParams){
            $exitConditionMet = $true
            $msgError =  "[{0}]:: {1}" -f $METHOD_NAME, "There is no settings with the label '$myLabel'."
            Write-Error $msgError; $Error[0]
        }

        if($exitConditionMet){
            return
        }

        switch($myLabel){
            'DisplayMessage' {
                [array]$UtilityParamList        = $myUtilityParams.keys
                [array]$InputUtilityParamList   = $fromSender.UtilityParamsTable.keys
                foreach($inputUtilityParam in $InputUtilityParamList){
                    if($utilityParamList -notcontains $inputUtilityParam){
                        $exitConditionMet = $true
                        $msgError =  "[{0}]:: {1}" -f $METHOD_NAME, "The utility parameter '$inputUtilityParam' is not defined."
                        Write-Error $msgError; $Error[0]
                        return
                    }
                }

                $this.UtilitySettings.DisplayMessage.DebugOn     = $fromSender.UtilityParamsTable.DebugOn
                $this.UtilitySettings.DisplayMessage.Mute        = $fromSender.UtilityParamsTable.Mute
                $this.UtilitySettings.DisplayMessage.FeedBack    = $fromSender.UtilityParamsTable.FeedBack 
            }
        }
    }
    [void]DisplayMessage([hashtable]$fromSender){
        <#
        #example usage:
        $displayMsgParams = @{
            Message         = 'test'
            Type     = 'debug'
            Category = 'debug'
        }
        $util.DisplayMessage($displayMsgParams)
        #>
        # all methods define there method name
        $METHOD_NAME        = "DisplayMessage"
        $exitConditionMet   = $false
        # the validation params are defined, making sure the user inputs the correct properties
        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })
        [string]$myCategory  = $fromSender.Category
        [string]$myType      = $fromSender.Type

        $feedBackTypeList   = @('success','warning','informational')
        $debugTypeList      = @('debug')
        $msgError           = [string]
        switch($myCategory){
            "FeedBack"  {
                if($feedBackTypeList -notcontains $myType){
                    $exitConditionMet = $true
                    $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"The message type '$($myType)' is undefined under category 'Feedback'."
                }
            }
            "Debug"     {
                if($debugTypeList -notcontains $myType){
                    $exitConditionMet = $true
                    $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"The message type '$($myType)' is undefined under category 'Debug'."
                }
            }
            default     {
                $exitConditionMet = $true
                $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"The message category '$($myCategory)' is undefined."
            }
        }
        if($exitConditionMet){
            Write-Error $msgError
        }
        
        $mySettings  = $this.GetUtilitySettingsTable(@{Label = 'DisplayMessage'})
        [string]$myMessage  = $fromSender.Message

        ($_ -eq "success") -and ($mySettings.FeedBack -eq $true)
        if($mySettings.Mute -eq $false){
            switch($myType){
                { ($_ -eq "success") -and ($mySettings.FeedBack -eq $true) }{
                    $msgDisplay = "[{0}]::[{1}]:: {2}" -f $METHOD_NAME,$myType,$myMessage
                    Write-Host $msgDisplay -ForegroundColor Green
                }
                { ($_ -eq "warning") -and ($mySettings.FeedBack -eq $true) }{
                    $msgDisplay = "[{0}]::[{1}]:: {2}" -f $METHOD_NAME,$myType,$myMessage
                    Write-Host $msgDisplay -ForegroundColor Yellow
                }
                { ($_ -eq "informational") -and ($mySettings.FeedBack -eq $true) }{
                    $msgDisplay = "[{0}]::[{1}]:: {2}" -f $METHOD_NAME,$myType,$myMessage
                    Write-Host $msgDisplay -ForegroundColor Cyan
                }
                { ($_ -eq "debug") -and ($mySettings.DebugOn -eq $true) }{
                    $msgDisplay = "[{0}]::[{1}]:: {2}" -f $METHOD_NAME,$myType,$myMessage
                    Write-Host $msgDisplay -ForegroundColor Magenta
                }
            }
        }
    }
    [void]AddUtilitySettings([hashtable]$fromSender){
        $METHOD_NAME =  "AddUtilitySettings"

        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })

        $myUtilitySettingsValue = $fromSender.Settings
        $myUtilitySettingLabel  = $fromSender.Label
        # no settings exists with that lable a.k.a key
        $canAddLabel = [bool]
        if(-not($this.GetUtilitySettingsTable(@{Label = $myUtilitySettingLabel}) -eq 0)){
            $canAddLabel = $false
        }else{
            $canAddLabel = $true
        }

        if($canAddLabel -eq $false){
            $this.DisplayMessage(@{
                Message 	= ("[{0}]:: {1}" -f $METHOD_NAME,"There is already settings with the label '$myUtilitySettingLabel'.")
                Type 		= "debug"
                Category 	= "debug"
            })
            return
        }
        
        $this.UtilitySettings.Add($myUtilitySettingLabel,$myUtilitySettingsValue)
    }
    [void]CreateCache([hashtable]$fromSender){
        $METHOD_NAME =  "CreateCache"

        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })

        $myCacheFolder = $fromSender.FolderPath
        $platformParameters = PlatformParameters

        # correct sepearator to correct one for the platform
        if($platformParameters.OS -eq 'onWindows'){
            $myCacheFolder = $myCacheFolder -replace '/',"\"
        }
        if($platformParameters.OS -eq 'onMac'){
            $myCacheFolder = $myCacheFolder -replace '\\','/'
        }
        if($platformParameters.OS -eq 'onLinux'){
            $myCacheFolder = $myCacheFolder -replace '\\','/'
        }
        $charArray = $myCacheFolder.ToCharArray()
        $lastFolderPathChar = $charArray[-1]
        
        # drops trailing separator if there is one
        if($lastFolderPathChar -eq $platformParameters.Separator){
            $pathLength = $myCacheFolder.Length
            $myCacheFolder = $myCacheFolder.Substring(0,($pathLength-1))
        }

        # dynamic path is given full path if dynamic path is used
        $isDynamicPath = [bool]
        if($myCacheFolder -match '(^.)(.*)'){
            $isDynamicPath = $true
        }else{
            $isDynamicPath = $false
        }
        if($isDynamicPath){
            $myCacheFolder  = $myCacheFolder -replace "\.",''
            $currentPath    = (Get-Location).Path
            $myCacheFolder  = "{0}{1}"  -f $currentPath,$myCacheFolder
        }

        $this.CreateItem(@{
            ItemType = "Folder"
            Path     = $myCacheFolder
        })

        $myCacheFile = $fromSender.FileName
        $mycharArray = $myCacheFile.ToCharArray()
       

        if($platformParameters.OS -eq 'onWindows'){
            $myCacheFile = $myCacheFile -replace '/',"\"
        }
        if($platformParameters.OS -eq 'onMac'){
            $myCacheFile = $myCacheFile -replace '\\','/'
        }
        if($platformParameters.OS -eq 'onLinux'){
            $myCacheFile = $myCacheFile -replace '\\','/'
        }

        $leadingSeparator =  $mycharArray[0]
        if($leadingSeparator -eq $platformParameters.separator){
            $myCacheFile = $myCacheFile.Substring(1)
        }

        $myCacheFilePath = "{0}{1}{2}" -f $myCacheFolder,$platformParameters.Separator,$myCacheFile
        if(-not($myCacheFilePath -match '(.*)(.json$)')){
           $myCacheFilePath = "{0}{1}" -f $myCacheFilePath,".json"
        }

        $this.CreateItem(@{
            ItemType = "File"
            Path     = $myCacheFilePath
        })

        $myLabel = $fromSender.Label
        $this.AddUtilitySettings(@{
            Label       = $myLabel
            Settings    = @{Path = $myCacheFilePath}
        })
    }
    [void]CacheConfiguration([hashtable]$fromSender){
        $METHOD_NAME =  "CacheConfiguration"

        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })


        $myConfiguration = $fromSender.Configuration
        $myLabel = $fromSender.Label
        $myFolderPath = $fromSender.FolderPath
        $myFileName = $fromSender.FileName

        # if the cache is there, then it will just create the label
        $this.CreateCache(@{
            Label       = $myLabel
            FolderPath  = $myFolderPath
            FileName    = $myFileName
        })

        # there will alwasy be a setting to get here
        $mySettings = $this.GetUtilitySettingsTable(@{Label = $myLabel})
        $mySettingsPath = $mySettings.Path

        $myCache = Get-Content -path $mySettings.Path

        # is the cache nulled out
        $convertedConfiguration = $null
        if($null -eq $myCache){
            $canConvert = [bool]
            try{
                $canConvert = $true
                $convertedConfiguration = $myConfiguration | ConvertTo-Json -ErrorAction Stop
            }catch{
                $canConvert = $false
            }

            if(-not($canConvert)){
                $msgError = ("[{0]:: {1}") -f $METHOD_NAME,"Configuration is not in the correct json format."
                Write-Error -Message $msgError; $Error[0]
                return
            }

            Set-Content -Path $mySettingsPath -Value $convertedConfiguration
        }

        # only when overwrite is true do we care truely refresh 
        $overWrite = $fromSender.Overwrite
        if(-not($null -eq $myCache)){
            if($overWrite){
                $canConvert = [bool]
                try{
                    $canConvert = $true
                    $convertedConfiguration = $myConfiguration | ConvertTo-Json -ErrorAction Stop
                }catch{
                    $canConvert = $false
                }
    
                if(-not($canConvert)){
                    $msgError = ("[{0]:: {1}") -f $METHOD_NAME,"Configuration is not in the correct json format."
                    Write-Error -Message $msgError; $Error[0]
                    return
                }
                Set-Content -Path $mySettingsPath -Value $convertedConfiguration
            }
        }
    }
    [psobject]ReadCache([hashtable]$fromSender){
        $METHOD_NAME = "ReadCache"
        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })
        $myLabel = $fromSender.Label
        $mySettings = $this.GetUtilitySettingsTable(@{Label = $myLabel})

        $myPath = $mySettings.Path
        if($myPath -eq 0){
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"There is no setting with label '$myLabel'."
            Write-Error -Message $msgError; 
            return $Error[0]
        }

        $myCacheData = Get-Content -path $myPath
        $myConvertedCache = $myCacheData | Convertfrom-json
        return $myConvertedCache
    }
    [void]RemoveCache([hashtable]$fromSender){
        $METHOD_NAME        = "RemoveCache"
        $this.InputKeysValidation(@{
            MethodName          = $METHOD_NAME
            UserInputHashtable  = $fromSender
        })
        
        $myLabel = $fromSender.Label
        $mySettings = $this.GetUtilitySettingsTable(@{Label = $myLabel})

        $myPath = $mySettings.Path
        if($myPath -eq 0){
            $msgError = "[{0}]:: {1}" -f $METHOD_NAME,"There is no setting with label '$myLabel'."
            Write-Error -Message $msgError; $Error[0]
            return
        }
        $this.UtilitySettings.Remove($myLabel)
        Remove-Item -Path $myPath
    }
}