Import-Module .\PSUTILITIES.psd1
$PSUTILITIES =  PSUTILITIES
Import-Module .\PSLOGGER.psd1





Remove-Module PSUTILITIES

Get-Module
Platform


     #region: test ReadCacheConfiguration
     $fromSender = @{
        Configuration   = $configurationtable
        FolderPath      = '.\TEST2'
        FileName        = '\myConfig1.json' 
    }
    $PSUTILITIES.ReadMyCacheConfiguration($fromSender)


$test = [pscustomobject]@{name = 'test'}

$configurationtable = @{this = 'tat'}


$PSUTILITIES.CreateCache(@{
    FolderPath  = ".\TEST2"
    FileName    = "\myConfig1.json"
})

$fromSender = @{
    ConfigurationLabel  = "TestConfig"
    Configuration       = $configurationtable
    FolderPath          = ".\TEST2"
    FileName            = "\myConfig1.json"
}
$PSUTILITIES.CacheConfiguration($fromSender)

$PSUTILITIES.GetUtilitySettingsTable(@{UtilityName = 'Configuration'})
$PSUTILITIES.UtilitySettings.Configuration.keys



$PSUTILITIES.GetUtilitySettingsTable(@{UtilityName = 'DisplayMessage'})

$validationParams = @{
    MethodName          = $METHOD_NAME
    UserInputHashtable  = $fromSender
}



$PSUTILITIES.InputKeysValidation(@{
    MethodName          = 'TestItemExists'
    UserInputHashtable  =  @{
        Key21 = "value1"
        Key22 = "Value2"
    }
})





$methodParams = @{
    MethodName = 'TestItemExists'
    KeysList = @('key1','key2')
}
$PSUTILITIES.AddMethodParamstable($methodParams)


# if you want to know the keys required by a method
$PSUTILITIES.GetMethodParamstable(@{ MethodName = 'CreateItem'})

# to get examples of how things works
$PSUTILITIES.GetExamples('CreateItem')

$PSUTILITIES.GetUtilityMethodList(@{GetUtilityMethodList = $true})



$PSUTILITIES.CreateItem(@{
    ItemType = "Folder"
    Path     = ".\CacheFolder"
})

$PSUTILITIES.CreateItem(@{
    ItemType = "File"
    Path     = ".\CacheFolder\LoggingCache22.txt"
})

$fromSender = @{
    Label ="LoggingCache2" 
    Settings = @{}
}


$path = '\test'

$fromSender = @{
    Configuration       = @{Test  = 'test2'}
    FolderPath          = '.\CacheFolder'
    FileName            = '\LoggingCache2.txt'
    ConfigurationLabel  = "LoggingCache2"
}




<#
AddUtilitiesSettings should be used when you want to add defined values that 
will be referenced later
#>
$PSUTILITIES.GetUtilitySettingsTable(@{Label = "LoggingdCache5"})
$PSUTILITIES.AddUtilitySettings(@{
    Label = "Test"
    Settings = @{This = "mySettings"}
})


# even if the config already exist, the label will be catologed
$PSUTILITIES.CreateCache(@{
    Label       = "LoggingCache5"
    FolderPath  = ".\CacheFolder"
    FileName    = "LoggingCache5"
})


# cache will only ignore overwrite if its null to begin with
# when overwrite is true, it till update it, when its false, it wont update it
$PSUTILITIES.CacheConfiguration(@{
    Configuration = @{this = "this is what i want to save"}
    Label       = "LoggingCache5"
    FolderPath  = ".\CacheFolder"
    FileName    = "LoggingCache6"
    Overwrite   = $true
})


# remeber that in order to read the cache you would have to first cached something
# otherwsie you dont have a label to link to it
$PSUTILITIES.ReadCache(@{
    Label = "Item2"
})

$PSUTILITIES.RemoveCache(@{
    Label = "LoggingCache5"
})


$list = @(
    "item1","Item2",    "item3","Item4",    "item5","Item6"
)

foreach($listItem in $list){
    $PSUTILITIES.CacheConfiguration(@{
        Configuration = @{this = "this is what i want to save"}
        Label       = $listItem
        FolderPath  = ".\CacheFolder"
        FileName    = $listItem
        Overwrite   = $true
    })
}