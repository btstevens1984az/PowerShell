# Purpose: TestAttributes — General-purpose PowerShell utilities.
function Test-Attributes
{
    Param(
        # Computer name can be passed in using
        # -ComputerName <value>
        # -CN <value>
        # -MachineName <value>
        [Alias("CN","MachineName")]
        [string]$ComputerName,

        # Mandatory parameter that can be null or an empty string
        [parameter(Mandatory=$true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Namespace,

        # Mandatory parameter that can be an empty collection
        [parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [string[]]$Location,

        # Must specify between 2 and 5 area codes
        [ValidateCount(2,5)]
        [int[]]$AreaCode,

        # Username must be between 6 and 30 characters long (inclusive)
        [ValidateLength(6,30)]
        [string]$Username,

        # Only allow strings that are valid social security numbers
        [ValidatePattern("\d{3}-\d{2}-\d{4}")]
        [string]$SocialSecurityNumber,

        # Pick any number from 100 to 200 (inclusive)
        [ValidateRange(100,200)]
        [int]$PickANumber,

        # Only allow even numbers
        [ValidateScript({$_ % 2 -eq 0})]
        [int]$EvenNumbersOnly,

        # Only allow the colors of a US traffic light
        [ValidateSet("green", "yellow", "red")]
        [string]$TrafficLight,
        
        # Allow empty strings, but not null strings
        [ValidateNotNull()]
        [string]$EmptyStringsOk,

        # String must be at least one character in length
        [ValidateNotNullOrEmpty()]
        [string]$AnyValue
    )

    $PSBoundParameters
}

# Will prompt for Location
Test-Attributes -Namespace root

# Will throw an error on validating evennumbersonly parameter
Test-Attributes -EvenNumbersOnly 3 -Namespace root -Location NY 

# Will succeed with CN as alias for ComputerName
Test-Attributes -CN sv-001 -Namespace root -Location NY 


Test-Attributes -CN sv-001 -Namespace root -Location NY -SocialSecurityNumber "123-56-0000" -TrafficLight green