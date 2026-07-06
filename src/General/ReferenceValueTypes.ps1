# Purpose: ReferenceValueTypes — General-purpose PowerShell utilities.
#reference Types
#https://msdn.microsoft.com/en-us/library/490f96s2(v=vs.90).aspx

$myObj1 = [pscustomobject]@{
                                prop1="test"
                                prop2="test2"
                            }
#reference is copied by value, but still references the same object
$myObj2 = $myObj1
$myObj1.prop1 = "test3"
$myobj2.prop1

#null out reference but object is still there
$myObj1 = $null
$myObj2

#value types
#https://msdn.microsoft.com/en-us/library/s1ax56ch(v=vs.90).aspx
$test = 123
$test2 = $test
$test = 1234
$test2
$test


