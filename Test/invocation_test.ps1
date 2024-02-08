$ErrorActionPreference = "Stop"
Import-Module .\PSUTILITIES.psd1
$PSUTILITIES =  PSUTILITIES
Remove-Module PSUTILITIES

$PSUTILITIES.GetExamples('CreateItem')

$PSUTILITIES.CacheConfiguration(@{
    Label               = "TestConfig"
    Configuration       = @{}
    FolderPath          = ".\TEST2"
    FileName            = "\myConfig1.json"
})

$PSUTILITIES.GetUtilitySettingsTable(@{Label = 'Configuration'})
$PSUTILITIES.GetUtilitySettingsTable(@{Label = 'DisplayMessage'})


$PSUTILITIES.AddMethodParamstable(@{
    MethodName = 'TestItemExists'
    KeysList = @('key1','key2')
})
$PSUTILITIES.GetMethodParamstable(@{ MethodName = 'TestItemExists'})
$PSUTILITIES.GetUtilityMethodList(@{GetAllMyUtilities = $true})

$PSUTILITIES.CreateItem(@{
    ItemType = "Folder"
    Path     = ".\CacheFolder"
})

$PSUTILITIES.CreateItem(@{
    ItemType = "File"
    Path     = ".\CacheFolder\LoggingCache22.txt"
})


$PSUTILITIES.AddUtilitySettings(@{
    Label = "Test"
    Settings = @{This = "mySettings"}
})
$PSUTILITIES.GetUtilitySettingsTable(@{Label = "Test"})


$PSUTILITIES.CreateCache(@{
    Label       = "LoggingCache5"
    FolderPath  = ".\CacheFolder"
    FileName    = "LoggingCache5"
})


# cache will only ignore overwrite if its null to begin with
# when overwrite is true, it till update it, when its false, it wont update it
$PSUTILITIES.CacheConfiguration(@{
    Configuration = @{}
    Label       = "Values1"
    FolderPath  = ".\CacheFolder"
    FileName    = "LoggingCache6"
    Overwrite   = $true
})

# remeber that in order to read the cache you would have to first cached something
# otherwsie you dont have a label to link to it
$PSUTILITIES.ReadCache(@{
    Label = "Values1"
})

$PSUTILITIES.RemoveCache(@{
    Label = "Values1"
})