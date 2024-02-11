## Importing the PSUTILITIES Module:
To utilize the functionalities provided by the PSUTILITIES module, follow these steps to import the module:

-   Open a PowerShell session.
-   Navigate to the directory containing the PSUTILITIES module.
-   Run the following command to import the module:

```powershell
Import-Module .\PSUTILITIES ; $PSUTILITIES =  PSUTILITIES
```
>**NOTE:** In this example, a path where the module is located is being used. Make sure you are using the appropriate method on importing for where your have stored the this module and its contents.
>

</b>

## Caching Configuration:
The `PSUTILITIES` module provides a convenient function for caching configuration. You can use the `$PSUTILITIES.CacheConfiguration` function as follows:

```powershell
$PSUTILITIES.CacheConfiguration(@{
    Label               = "my-Item-label"
    Configuration       = @{}
    FolderPath          = ".\foldername\"
    FileName            = "\mycache"
})
```

</br>

>Replace the parameters with your specific values. This function allows you to cache configurations with a specified label, folder path, and file name.


## Retrieving Utility Settings:

The `PSUTILITIES` module includes a useful function for retrieving utility settings tables. You can use the `$PSUTILITIES.GetUtilitySettingsTable` function to get information based on a specified label. Here's an example:
```powershell
$PSUTILITIES.GetUtilitySettingsTable(@{Label = 'my-Item-label'})
```

```powershell
c:\
# when a label does not match up to any previous configuration cache, it will return 0
0

c:\
# when the label provided does match the output will look like this:
Name                           Value
----                           -----
Path                           C:\LocalRepo\PSUTILITIES\foldername\mycache.json

```

## Adding Method Parameters:
If you find yourself using hashtables as input to your own methods, you will quickly find that you'll need to handle the keys in the hashtable, making sure they're included in the input. Using this in your method will handle that for you. If any key in the keylist is not inlcuded in the hashtable provided, it will error.

To best descripe this functionality, let's work with an example. Here I have created simple class



```powershell
$PSUTILITIES.AddMethodParamstable(@{
    MethodName = 'MyMethodName'
    KeysList = @('key1','key2')
})
```

```powershell
$PSUTILITIES.CreateItem(@{
    ItemType = "Folder"
    Path     = ".\FolderName"
})

```

```powershell
$PSUTILITIES.CreateItem(@{
    ItemType = "File"
    Path     = ".\FolderName\fileName.txt"
})
```

```powershell
$PSUTILITIES.AddUtilitySettings(@{
    Label = "SomeSetting"
    Settings = @{This = "my setting"}
})
```

```powershell
$PSUTILITIES.CreateCache(@{
    Label       = "CacheLabel"
    FolderPath  = ".\CacheFolder"
    FileName    = "CacheFileName"
})

```
```powershell
$PSUTILITIES.CacheConfiguration(@{
    Configuration = @{MyKey = "MyValue"}
    Label       = "CacheLabel"
    FolderPath  = ".\CacheFolder"
    FileName    = "LoggingCache6"
    Overwrite   = $true
})
```

```powershell
$PSUTILITIES.ReadCache(@{
    Label = "CacheLabel"
})

```

```powershell
$PSUTILITIES.RemoveCache(@{
    Label = "CacheLabel"
})

```

```powershell

```