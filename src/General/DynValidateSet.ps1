# Purpose: DynValidateSet — General-purpose PowerShell utilities.
function  Test-DynValidationSet
{
    [cmdletbinding()]
    param($path)
    DynamicParam
        {
           #if ($path -like "c:*")
           #{
                $attributes = new-object System.Management.Automation.ParameterAttribute
                $attributes.ParameterSetName = "__AllParameterSets"
                $attributes.Mandatory = $false
                $attributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
                $attributeCollection.Add($attributes)
                $dirList = Get-ChildItem -Path $path -Directory -Include temp*| Select-Object -ExpandProperty FullName
                $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($dirList)
                $attributeCollection.Add($ValidateSetAttribute)
                $dynParam1 = new-object -Type System.Management.Automation.RuntimeDefinedParameter("TempDirs", [string], $attributeCollection)
            
                $paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
                $paramDictionary.Add("TempDirs", $dynParam1)
                return $paramDictionary
            #}
        }
   

   process{
               if ($tempdirs)
                {dir $tempdirs}
                else
                { dir $path -Directory}
    }
}

function  Test-DynValidationSetAD
{
    [cmdletbinding()]
    param([switch]$test)
    DynamicParam
        {
                $attributes = new-object System.Management.Automation.ParameterAttribute
                $attributes.ParameterSetName = "__AllParameterSets"
                $attributes.Mandatory = $false
                $attributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
                $attributeCollection.Add($attributes)
                $servernames = (Get-adcomputer -Filter "operatingsystem -like '*2016*'").name
                $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($servernames )
                $attributeCollection.Add($ValidateSetAttribute)
                $dynParam1 = new-object -Type System.Management.Automation.RuntimeDefinedParameter("NewServer", [string], $attributeCollection)
            
                $paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
                $paramDictionary.Add("NewServer", $dynParam1)
                return $paramDictionary
            #}
        }
   

   process{
            $PSBoundParameters
            Get-adcomputer -Identity $NewServer | Out-GridView
    }
}


#Show-Command Test-DynValidationSetAD