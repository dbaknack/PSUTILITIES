$ErrorActionPreference = "Stop"
Import-Module .\PSUTILITIES ; $PSUTILITIES =  PSUTILITIES

$PSUTILITIES.GetExamples('CacheConfiguration')

$PSUTILITIES.CacheConfiguration(@{
    Label               = "my-Item-label"
    Configuration       = @{}
    FolderPath          = ".\foldername\"
    FileName            = "\mycache"
})


Class Example{
    $PSUtil = (PSUTILITIES)

    
    [void]MyMethod([hashtable]$fromSender){
        $this.PSUtil.InputKeysValidation(@{
            MethodName          = 'MyMethod'
            UserInputHashtable  = $fromSender
        })
    }
}

$Example.PSUtil.INPUT_METHOD_PARAMS_TABLE.MyMethod

$Example.PSUtil.GetUtilityMethodList(@{GetAllMyUtilities = $true})
$Example.PSUtil.GetMethodParamstable(@{ MethodName = 'MyMethod'})
$Example.PSUtil.AddMethodParamstable(@{MethodName = 'MyMethod';KeysList = @('key1','key2')})
$Example.PSUtil.InputKeysValidation(@{
    MethodName          = 'MyMethod'
    UserInputHashtable  = $fromSender
})
$fromSender
$Example = [Example]::new()
$Example.MyMethod(@{
 
})

$PSUTILITIES.GetUtilitySettingsTable(@{Label = 'my-Item-label'})


$PSUTILITIES.AddMethodParamstable(@{
    MethodName = 'MyMethodName'
    KeysList = @('key1','key2')
})

$PSUTILITIES.GetMethodParamstable(@{ MethodName = 'MyMethodName'})
$PSUTILITIES.GetUtilityMethodList(@{GetAllMyUtilities = $true})

$PSUTILITIES.CreateItem(@{
    ItemType = "Folder"
    Path     = ".\FolderName"
})

$PSUTILITIES.CreateItem(@{
    ItemType = "File"
    Path     = ".\FolderName\fileName.txt"
})


$PSUTILITIES.AddUtilitySettings(@{
    Label = "SomeSetting"
    Settings = @{This = "my setting"}
})

$PSUTILITIES.GetUtilitySettingsTable(@{Label = "SomeSetting"})


$PSUTILITIES.CreateCache(@{
    Label       = "CacheLabel"
    FolderPath  = ".\CacheFolder"
    FileName    = "CacheFileName"
})

# cache will only ignore overwrite if its null to begin with
# when overwrite is true, it will update it, when its false, it wont update it
$PSUTILITIES.CacheConfiguration(@{
    Configuration = @{MyKey = "MyValue"}
    Label       = "CacheLabel"
    FolderPath  = ".\CacheFolder"
    FileName    = "LoggingCache6"
    Overwrite   = $true
})

# remeber that in order to read the cache you would have to first cached something
# otherwsie you dont have a label to link to it
$PSUTILITIES.ReadCache(@{
    Label = "CacheLabel"
})

$PSUTILITIES.RemoveCache(@{
    Label = "CacheLabel"
})