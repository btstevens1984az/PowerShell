# Purpose: BrowseActiveDirectorySchema — Active Directory user, group, and domain administration.
# ------------------------------------------------------------------------
# DATE: 11/6/2008
#
# KEYWORDS: Active Directory Shema, .NET framework
# DirectoryServices.ActiveDirectory.ActiveDirectorySchema
# switch statement, functions
#
# COMMENTS: This script retrieves the schema. It will
# list all classes in AD. It will also list the mandatory
# or optional properties of a class you select
#
# ------------------------------------------------------------------------

Param($action,$class, [switch]$help)

Function GetHelp()
{
  $helpText= `
@"
 DESCRIPTION:
 NAME: BrowseActiveDirectorySchema.ps1
 Browse Active Directory Schema. Lists Classes, and properties. 

 PARAMETERS: 
 -Action <L(ist all classes), M(andatory), O(ptional), F(ind)>
 -Class class to search: user, computer, person, contact etc
 -Help displays this help topic

 SYNTAX:
 BrowseActiveDirectorySchema.ps1 -A L
 Lists the name of each class defined in the AD schema

 BrowseActiveDirectorySchema.ps1 -A M -c user
 Lists the mandatory properties of the user class

 BrowseActiveDirectorySchema.ps1 -A O -c computer
 Lists the optional properties of the computer class

 BrowseActiveDirectorySchema.ps1 -A F -c user
 Lists all Active Directory Classes that contain the word user 
 in the actual class name

 BrowseActiveDirectorySchema.ps1 -Action Find -c user
 Lists all Active Directory Classes that contain the word user 
 in the actual class name
 
 BrowseActiveDirectorySchema.ps1 -help
 Prints the help topic for the script
"@ #end helpText
  $helpText
} #end GetHelp

Function GetADSchema($Action, $class)
{
 $schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
 Switch ($Action)
  {
   "classes" { 
              $schema.FindAllClasses() | 
              Select-Object -Property Name 
             }
   "Mandatory" 
             {
              "Mandatory Properties of $class object"
              ($schema.FindClass("$class")).MandatoryProperties | 
               Format-Table -Property Name, Syntax, IsSingleValued -AutoSize 
             }
   "Optional" 
             {
              "Optional Properties of $class object"
              "This might take a few seconds ..."
              ($schema.FindClass("$class")).OptionalProperties | 
              Format-Table -Property Name, Syntax, IsSingleValued -AutoSize 
             }
   "Find" 
             {
              $schema.FindAllClasses() | 
              Where-Object { $_.name -match "$class" } |
              Select-Object -property name
             }
   DEFAULT {"$action is not a valid action." ; GetHelp ; Exit}
  }
} #end GetADSchema

Function GetAllClasses()
{
 GetAdSchema("classes")
} #end GetAllClasses

Function GetMandatory($class)
{
 GetAdSchema -action "Mandatory"  -class $class 
} #end GetMandatory

Function GetOptional($class)
{
 GetAdSchema -action "Optional"  -class $class 
} #end GetOptional

Function FindClasses($class)
{
 GetAdSchema -action "Find" -class $class
} #end FIndClasses
# *** Entry Point to Script ***
if($help) { GetHelp ; Exit }

Switch ($action)
{
 "L" {GetAllClasses ; Exit}
 "M" {GetMandatory($class) ; Exit}
 "O" {GetOptional($class) ; Exit}
 "F" {FindClasses($class) ; Exit}
 DEFAULT { "$action is not a valid action." ; GetHelp ; Exit} 
}

