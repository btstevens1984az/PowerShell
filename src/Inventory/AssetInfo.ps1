# Purpose: AssetInfo — Hardware and software inventory collection.
Enum AssetCategory
{
    Hardware
    Software
}
class AssetInfo
{
    [GUID]$AssetIdentifier = (new-guid) 
    [AssetCategory]$AssetCategory = "Hardware"

}

