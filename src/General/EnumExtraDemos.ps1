# Purpose: EnumExtraDemos — General-purpose PowerShell utilities.
enum MyEnum
{
    Enum1
    Enum2 
    Enum3 = 42
    Enum4 = [int]::MaxValue
    #can initialize an enum in terms of another enum
    OSType = [PlatformID]::Win32NT
    #Cannot set value = to invoked commands
    #Enum6 = (get-process)[0].Id
}
#use Enum
[MyEnum]::Enum1
[MyEnum]42

#Display Underlying values
[MyEnum]::Enum1.value__
[MyEnum]::Enum2.value__
[MyEnum]::Enum3.value__
[MyEnum]::Enum4.value__
[MyEnum]::OsType.value__

#Bitwise Enum
Enum MyBitFlag
{
    None = 0
    BitFlag1 = 1
    BitFlag2 = 2
    BitFlag3 = 4
    #Bit2and3 = 6
    BitFlag4 = 8
}
#Perform bitwise comparisons
[MyBitFlag]::BitFlag2 -band [MyBitFlag]::BitFlag3
[MyBitFlag]::BitFlag2 -bor [MyBitFlag]::BitFlag3
#Typecast Value to BitFlag
([MyBitFlag]([MyBitFlag]::BitFlag2 -bor [MyBitFlag]::BitFlag3)).gettype().FullName
[MyBitFlag]$test = [MyBitFlag]::BitFlag2 + [MyBitFlag]::BitFlag3
$test -band [MyBitFlag]::BitFlag3



############Extra Demos################################################

#Common System.Enum Methods
#Display enum names
[enum]::GetNames([MyEnum])

#Get Enum value from underlying value
[enum]::GetName([MyEnum],42)