# has snippet - imf
Function UTILITIES { . ./Private/Classes.ps1; [Utilities]::new() }


class PSLogger2{
    $Configuration = @{
        Headings = @{
            column_01 = 'LogID'
            column_02 = 'UserName'
            column_03 = 'DateTime'
            column_04 = 'HostName'
            column_05 = 'Message'
        }
        Identity = @{
            seed        = 1
            increment   = 1
        }
        DateTimeFormat      = "yyyy-MM-dd HH:mm:ss.fff"
        CycleLogs           = $true
        MaxLogFiles         = 10
        MaxLogFileEntries   = 10
        LogFileProperties   = @{
            LogsFolderPath  = "./Private/Configuration.json"
            Name            = "test"
            Extension       = '.log'
            Delimeter       = ','
        }
        LogFileID = 0
    }
   $UTILITIES = (UTILITIES)
    [void]CreateCache([hashtable]$fromSender){
        $myConfigurationTable = $this.Configuration
        $configurationJson = $myConfigurationTable | ConvertTo-Json
        #example usage:
        $displayMsgParams = @{
            Message         = 'test'
            MessageType     = 'debug'
            MessageCategory = 'debug'
        }
        $this.UTILITIES.DisplayMessage($displayMsgParams)
    }
}
$PSLogger2 = [PSLogger2]::new()

#region: control utilities
# snippet - Util-Ctrl
$PSLogger2.UTILITIES.UpdateUtilitySettings(@{
    UtilityName = 'DisplayMessage'
    UtilityParamsTable = @{
        DebugOn     = $true
        Feedback    = $true
        Mute        = $true
    }
})
$PSLOGGER2.UTILITIES.UpdateUtilitySettings(@{
    UtilityName = 'DisplayMessage'
    UtilityParamsTable = @{
        DebugOn     = $false
        Feedback    = $true
        Mute        = $false
    }
})


# snippet - Util-Ctrl
$PSLogger2.UTILITIES.CacheConfiguration(@{
    Configuration       = $PSLogger2.Configuration
    FolderPath          = './CacheFolder'
    FileName            = '/LoggingCache.txt'
    ConfigurationLabel  = "LoggingCache"
})

# snippet - Util-Ctrl
$PSLogger2.UTILITIES.UpdateCacheConfiguration(@{
    Configuration       = $PSLogger2.Configuration
    ConfigurationLabel  = 'LoggingCache'
})



$PSLogger2.UTILITIES.ReadMyCacheConfiguration(@{
    ConfigurationLabel = 'LoggingCache'
})

$PSLogger2.UTILITIES.GetUtilitySettingsTable(@{
    UtilityName = 'Configuration'
})
#endregion: control utilties





class PSLogger{
    $LogFormatTable = @{
        Properties = @(
            "Headings",
            "EntryIdentity",
            "LogIdentity",
            "DateTimeFormat",
            "Delimeter",
            "CycleLogs",
            "Interval",
            "Retention",
            "LogFilePath",
            "LastDelimeterPath",
            "LogFileName",
            "TrackedValuesFile",
            "EnableLogging"
        )
        Headings = @(
            "UserName",
            "DateTime",
            "HostName",
            "Message"
        )
    }

    $ConfigFilePath = [string]"./Private/Configuration.json"
    $Configuration  = $test.GetConfiguration(@{Reload = $true})
    $TrackedValues  = $this.GetTrackedValues(@{Reload = $true})

    [psobject]ValidateConfiguration([hashtable]$fromSender){
        $allowedPropertiesList = $this.LogFormatTable.Properties
        $RESULTS_TABLE  =   @{
            isSuccessfull   =   [bool]
            Data            =   [psobject]
        }
        $propertiesList = $fromSender.keys
        foreach($property in ($propertiesList)){
            if($allowedPropertiesList -notcontains $property){
                $RESULTS_TABLE.isSuccessfull = $false
            }else{
                $RESULTS_TABLE.isSuccessfull = $true
            }
        }
        if($RESULTS_TABLE.isSuccessfull -eq $false){
            Write-Error -Message "[ValidateConfiguration]:: not all the properties in your configuration file are allowed" -Category "InvalidData" 
        }
        $RESULTS_TABLE.Data = $propertiesList
        return $RESULTS_TABLE
    }

    [void]SetConfiguration([hashtable]$fromSender){
        $this.Configuration = $fromSender
    }

    [void]SetTrackedValues([hashtable]$fromSender){
        $this.TrackedValues = $fromSender
    }

    [psobject]LoadConfiguration(){
        $RESULTS_TABLE  =   @{
            isSuccessfull   =   [bool]
            Data            =   [psobject]
        }
        $preLoadedConfiguration = ((Get-Content $this.ConfigFilePath) | ConvertFrom-Json -AsHashtable)
        $RESULTS_TABLE = ($this.ValidateConfiguration($preLoadedConfiguration))
        $this.SetConfiguration($preLoadedConfiguration)
        return $RESULTS_TABLE
    }

    [void]LoadTrackedValues(){
        $props                  = $this.GetConfiguration(@{Reload = $false})
        $preLoadedTrackedValues = (Get-Content $props.TrackedValuesFile) | ConvertFrom-Json -AsHashtable
        $this.SetTrackedValues($preLoadedTrackedValues)
    }

    [psobject]GetConfiguration([hashtable]$fromSender){
        switch($fromSender.Reload){
            $true {
                $this.LoadConfiguration()
            }
        }
        return $this.Configuration
    }

    [psobject]GetTrackedValues([hashtable]$fromSender){
        switch($fromSender.Reload){
            $true {
                Write-Verbose -Message "[GetTrackedValues]::loading tracked values from disk..." -Verbose
                $this.LoadTrackedValues()
            }
            default{
                Write-Verbose -Message "[GetTrackedValues]::getting tracked values from class parameter(s)..." -Verbose
            }
        }
        return $this.TrackedValues
    }

    [psobject]RetentionPolicy([hashtable]$fromSender){
        $RESULTS_TABLE  =   @{
            isSuccessfull   = [bool]
            Data            = @{}
        }

        $RESULTS_TABLE.Data.Add("CanCreateNewFile",$true)
        if($fromSender.Reload){
            #Write-Verbose -Message "--+ Reloading configuration" -Verbose
        }else{
            #Write-Verbose -Message "--+ Not realoding configuration" -Verbose
        }
        $config         = $this.GetConfiguration($fromSender)
        $logFileList    = (Get-ChildItem -Path  $config.LogFilePath -Filter "*$($config.LogFileName)") 
        $retentionList  = $logFileList | 
        Select-Object Name, CreationTime, @{Name='CreationTimeDT'; Expression={[DateTime]::Parse($_.CreationTime)} } | 
        Sort-Object CreationTimeDT -Descending
  
        $mostRecentLog              =   ($this.GetCurrentLogFile(@{Reload = $false}))
        [string]$myInterval         =   $config.Interval.keys
        [string]$myIntervalValue    =   $config.Interval.values

        $DateTimeCommandString  = ('(Get-Date).Add{0}(-{1})' -f ($myInterval),($myIntervalValue))
        $scriptBlock            = [scriptblock]::Create($DateTimeCommandString)
        $DateTimeOffset         = Invoke-Command -ScriptBlock $scriptBlock

        if(($mostRecentLog.Data.mostRecentLog.CreationTime) -lt $DateTimeOffset){
            Write-Verbose -Message "--+ Per the retention policy, purging some files..." -Verbose
            $logFileList | Select-Object -Property * | Where-Object {$retentionList.Name -notcontains $_.Name} | Remove-Item
            
       }else{
            Write-Verbose -Message "[RetentionPolicy]:: per the retention policy, no new files can be created..." -Verbose
            $RESULTS_TABLE.Data.CanCreateNewFile = $false
       }
       return $RESULTS_TABLE
    }

    [psobject]GetCurrentLogFile($fromSender){
        $RESULTS_TABLE  =   @{
            isSuccessfull   = [bool]
            Data            = [psobject]
        }

        if($fromSender.Reload){
            Write-Verbose -Message "--+ Reloading configuration" -Verbose
        }else{
            Write-Verbose -Message "--+ Not Realoading configuration" -Verbose
        }

        $config = $this.GetConfiguration($fromSender)
        if( -not (Test-Path -Path "$($config.LogFilePath)")){
            $RESULTS_TABLE.isSuccessfull = $false
            Write-Error -Message "The path in your configuration file '$($config.LogFilePath)' is not reachable"
        }else{
            Write-Verbose -Message "--+ The path in your configuration file '$($config.LogFilePath)' is valid" -Verbose
        }

        $logFileList = (Get-ChildItem -Path  $config.LogFilePath -Filter "*$($config.LogFileName)")
        if($null -eq $logFileList){
            Write-Verbose -Message "--+ The log file location is empty" -Verbose
            $RESULTS_TABLE.isSuccessfull = $true
            $RESULTS_TABLE.Data = @{
                isNull          = $true
                mostRecentLog   = $null
            }
        }else{
            Write-Verbose -Message "--+ The log file location has '$($logFileList.count)' log files" -Verbose
            $RESULTS_TABLE.isSuccessfull = $true
            $RESULTS_TABLE.Data = @{
                isNull          = $false
                mostRecentLog   = $logFileList | Sort-Object -Property  LastWriteTime -Descending | Select-Object -First 1
            }
        }
        return $RESULTS_TABLE
    }

    [psobject]CreateLogFile([hashtable]$fromSender){
        $config     = $this.GetConfiguration($fromSender)
        $canCreateNewFile = $true

        if(($this.GetCurrentLogFile($fromSender)).Data.isNull){
            $resetTrackedValues = [ordered]@{
                LogFileID       = $config.LogIdentity[0]
                LastDelimeter   = $config.Delimeter
            }
            $resetTrackedValues = $resetTrackedValues  | ConvertTo-Json
            Set-Content -Path $config.TrackedValuesFile -Value $resetTrackedValues
        }else{
            Write-Verbose -Message "--+ Checking the retention values" -Verbose
            $canCreateNewFile = $this.RetentionPolicy(@{Reload = $true}).Data.CanCreateNewFile
        }
        
        $preFileName = "{0}_$(($config.LogFileName))"
        $posFileName = [string]
        $finalName = [string]

        $trackedVal = $this.GetTrackedValues($fromSender)
        $lastFileID = ($trackedVal).LogFileID

        if($config.CycleLogs -eq "false"){
            $posFileName = $preFileName -f $lastFileID
            $finalName = "$($config.LogFilePath)/$($posFileName)"

            if(-not (Test-Path -Path $finalName)){
                New-Item -Path $finalName -ItemType "File"
            }else{
                Write-host "log file $($finalName) already exists" -ForegroundColor Red
            }
        }else{
            $currentFileID = $lastFileID + $config.LogIdentity[1]
            $posFileName = $preFileName -f $currentFileID
            $finalName = "$($config.LogFilePath)/$($posFileName)"

            if(-not (Test-Path -Path $finalName)){
                if($canCreateNewFile){
                    New-Item -Path $finalName -ItemType "File"
                    $trackedVal.LogFileID = $currentFileID
                    $trackedVal = $trackedVal | ConvertTo-Json
                    Set-Content -Path $config.TrackedValuesFile -Value $trackedVal
                }
                else{
                    Write-Verbose -Message "--+ Can't create a new log file, the most recent log file is still within the retention period" -Verbose
                }
            }else{
                Write-Verbose -Message "--+ file already exists" -Verbose

            }
        }
        return $true
    }

    [psobject]SetLogEntry([string]$logThis){
        $props = $this.GetConfiguration(@{Reload = $false})
        
        $LogMessageList = @()
        $LogMessageOptionsTable = [ordered]@{
            UserName    =  (EvaluateOS).OS_USER
            DateTime    = (Get-Date).ToString($Props.DateTimeFormat)
            Message     = $logThis
            HostName    = (EvaluateOS).OS_HOST
        }
        foreach($heading in $props.Headings){
           $LogMessageList += $LogMessageOptionsTable[$heading]
        }
        return $LogMessageList
    }

    [void]ClearAllLogs(){
        Write-Verbose -Message "-+ [ClearAllLogs]" -Verbose
        $config = $this.GetConfiguration(@{Reload = $false})
        $logFileList = Get-ChildItem -path ($config.LogFilePath)  
        if($logFileList.Count -eq 0){
            Write-Verbose -Message "--+ No logs exists to remove" -Verbose
        }else{
            Write-Verbose -Message "--+ Removing '$($logFileList.count)' log files" -Verbose
            $logFileList | Remove-Item -Force
        }
        $this.ResetTrackedValues(@{
            Reload      = $false
            UseDefaults = $true}
        )
    }

    [void]ResetTrackedValues([hashtable]$fromSender){
        $METHOD_NAME                = "ResetTrackedValues"
        $METHOD_PARAMS_LIST         = @("Reload", "UseDefaults")
        [array]$USER_PARAMS_LIST    = $fromSender.Keys
        $exitConditionMet           = $false
        
        $this.UtilityHashtableValidation($fromSender)

        # guard clause: handle a null passed parameter
        if($USER_PARAMS_LIST.count -eq 0){
            $exitConditionMet = $true
        }
        if($exitConditionMet){
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
            return
        }

        #guard clause: the keys provided are the keys defined and no less
        $definedUserParamCount      = $METHOD_PARAMS_LIST.count
        $counter                    = 0
        foreach($methodParams in $METHOD_PARAMS_LIST){
            foreach($userParam in $USER_PARAMS_LIST){ $counter++ }
        }
        if($counter -ne $definedUserParamCount){
            $exitConditionMet = $true
        }
        if($exitConditionMet){
            return
        }
        

        $DEFAUL_TRACKED_VALUES_TABLE = [ordered]@{
            LogFileID = 0
            LastDelimeter = ","
        }
        
        $config = $this.GetConfiguration($fromSender)

        if( -not (Test-Path -Path $($config.TrackedValuesFile))){
            Write-Error -Message "--+the path for tracked values '$($config.TrackedValuesFile)' is not valid" -Category "ObjectNotFound"
        }else{
            Write-Verbose -Message "--+ The path for tracked values '$($config.TrackedValuesFile)' is valid" -Verbose
        }

        if($fromSender.UseDefaults){
            Set-Content -Path $config.TrackedValuesFile -Value ($DEFAUL_TRACKED_VALUES_TABLE | ConvertTo-Json)
            Write-Verbose -Message "--+ Reset tracked values with the defaults" -Verbose

        }else{
            Set-Content -Path $config.TrackedValuesFile -Value ($DEFAUL_TRACKED_VALUES_TABLE | ConvertTo-Json)
            Write-Verbose -Message "--+ Reset tracked values with the values in the configuration file '$($config.TrackedValuesFile)'" -Verbose
        }

    }

    [psobject]GetSeedProperties([hashtable]$fromSender){
        Write-Verbose -Message "-+ [GetSeedProperties]" -Verbose
        $RESULTS_TABLE  =   @{
            isSuccessfull   =   [bool]
            Data            =   [psobject]
        }

        if($fromSender.Reload){
            Write-Verbose -Message "--+ Reload configuration: 'true'" -Verbose
        }else{
            Write-Verbose -Message "--+ Reload configuration: 'false'" -Verbose
        }
        $config = $this.GetConfiguration($fromSender)
        $RESULTS_TABLE.Data = [ordered]@{
            Seedof      = $config.EntryIdentity[0]
            Incrementof = $config.EntryIdentity[1]
        }
        return $RESULTS_TABLE
    }

    [psobject]GetLastLogEntry(){
        $LogFilePath = ($this.GetCurrentLogFile(@{Reload = $false})).Data.mostRecentLog
        return Get-Content -Tail 1 -Path $LogFilePath
    }

    # input is a string
    [void]LogThis([string]$logThis){

        $props          = $this.GetTrackedValues(@{Reaload = $true})
        $config_props   = $this.GetConfiguration(@{Reload = $true})
        $Delimenter     = $config_props.Delimeter

        Write-Verbose -Message "-+ [LogThis]" -Verbose
        Write-Verbose -Message "--+ LastDelimeter: '$($props.LastDelimeter)'" -Verbose
        Write-Verbose -Message "--+ LogFileID: '$($props.LogFileID)'`n" -Verbose
        
        $SeedProps  = $this.GetSeedProperties(@{Reload = $false})
        
        Write-Verbose -Message "-+ [LogThis]" -Verbose
        $this.CreateLogFile(@{Reload = $true})
        $LogFilePath = ($this.GetCurrentLogFile(@{Reload = $true})).Data.mostRecentLog
        $lastEntryID = [int]

        $lastLine = $this.GetLastLogEntry()
        $setLogMessageHeadings = $false
        if($lastline){
            Write-Verbose "there was a last log entry" -Verbose
            $lastEntryID = [int]($lastLine.Split($props.LastDelimeter))[0]
        }else{
            Write-Verbose "Log is currently empty" -Verbose
            $setLogMessageHeadings = $true
            
            $lastEntryID = [int]($SeedProps.Data["Seedof"])
        }

        if($setLogMessageHeadings){
            $HeadingsList  = @('ID')
            $HeadingsList += ($config_props.Headings)
            $HeadingsList = $HeadingsList -join "$($config_props.Delimeter)"
            Add-Content -Path $LogFilePath -Value $HeadingsList
        }
        $lastEntryID = $lastEntryID + $SeedProps.Data["Incrementof"]
        $myLogEntry = @()
        $myLogEntry += $lastEntryID

        $myLogEntry += $this.SetLogEntry($logThis)

        $myLogEntry = $myLogEntry -join $Delimenter
        Write-Verbose "logging message" -Verbose

        Add-Content -Path $LogFilePath -Value $myLogEntry

        write-host "saving the current delimenter to be used as last delimenter on next run $Delimenter" -ForegroundColor cyan
        $props.LastDelimeter = $Delimenter
        $props = $props | ConvertTo-Json
        Set-Content -Path $config_props.TrackedValuesFile -value $props
    }
}

$test.ClearAllLogs()
$test.GetSeedProperties(@{Reaload = $false}).Data
$test= [PSLogger]::new()
$test.RetentionPolicy(@{Reload = $false})


$test.SetLogEntry()
$preLoadedConfiguration = ((Get-Content "./Private/Configuration.json") | ConvertFrom-Json -AsHashtable)
$test.ValidateConfiguration($preLoadedConfiguration)
$test.ResetTrackedValues(@{Reload = $true})
$test.GetLastLogEntry()
$lastLine = $test.GetLastLogEntry()
if($lastline){
    Write-Host "there was a last log entry"
    [int]($lastLine.Split(','))[0]
}else{
    Write-Host "Log is currently empty"
    #$lastEntryID = [int]($SeedProps["Seedof"])
}
$test.ConfigFilePath

$test.GetCurrentLogFile(@{Reload = $true}).Data.mostRecentLog.CreationTime
$test.GetCurrentLogFile(@{Reload = $false})



$test.GetTrackedValues(@{Reload = $false})
$test.GetTrackedValues(@{Reload = $true})
(Get-Date).Addseconds(-10)
#The count is not resettings
$test.CreateLogFile(@{Reload = $true})
$test.CreateLogFile(@{Reload = $false})

$test.RetentionPolicy(@{Reload = $true})
$test.RetentionPolicy(@{Reload = $false})

$test.ValidateConfiguration(
    $test.GetConfiguration(@{Reload = $true})
)

$test.ValidateConfiguration(
    $test.GetConfiguration(@{Reload = $false})
)

$test.LoadConfiguration()
$test.LoadTrackedValues()
$test.Configuration

# cant log this if there is no log file to hold this entry
$test.LogThis("this is something i want to track with a log entry")

function test-logging($message){
    $test.LogThis($message)
}

test-logging -message "hello"


$computed_Prop = @{name = 'Datetime2'; expression = {($_.CreationTime).ToString('yyyy-MM-dd HH:mm:ss.fff')}}
$logFileList    = (Get-ChildItem -Path  "./Test/Logs" ) 
test-logging -message "hello"
$logFileList | select 'name','LastWriteTime' ,$computed_Prop | Sort-Object -Property  "CreationTime" 

$retentionList  = $logFileList | Sort-Object -Property  "LastWriteTime" -Descending | Select-Object -First ($config.Retention.mostrecent -1)
        foreach($file  in $retentionList){
            write-host $file
        }



$test.GetSeedProperties($test.GetConfiguration(@{Reload = $true}))


(Get-ChildItem -Path ./Test/Logs).count

$test.GetTrackedValues(@{Reload = $true})

$test.GetTrackedValues(@{Reload = $false})

# when reload = $true then its read from disk

$test.GetConfiguration(@{Reload = $false})
$test.GetConfiguration(@{Reload = $true})

$test.CreateLogFile(@{Reload = $false})


$test.GetCurrentLogFile(@{Reload = $true})
$test.UsePadding





$files = Get-ChildItem -Path "./Test/Logs" | 
    Select-Object Name, CreationTime, @{Name='CreationTimeDT'; Expression={[DateTime]::Parse($_.CreationTime)} } | 
    Sort-Object CreationTimeDT

# Display the sorted files
$files
