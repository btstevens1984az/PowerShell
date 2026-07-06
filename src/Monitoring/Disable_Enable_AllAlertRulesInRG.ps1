<#
.SYNOPSIS
    Disables or Enables all Alert Rules in a given Azure Resource Group.
.DESCRIPTION
    This script gets all the rules in a given Azure Resource Group and either Disables them or Enables them depending
    on the presence of the Enable switch parameter. Default action (no -Enable) is to disable all the rules. Rules that are
    currently already disabled will stay disabled and vice versa depending on the presence of the Enable switch parameter.
.PARAMETER ResourceGroupName
    The name of the target Resource Group to operate on.
.PARAMETER Enable
    Switch parameter that will Enable all rules. Without using this parameter, the default behaviour is to disable all the 
    rules in the given Resource Group.
.EXAMPLE
    Disables all rules in the DevRG Resource Group.
    PS C:\scripts>Disable_Enable_AllAlertRulesInRG.ps1 -ResourceGroupName DevRG
.EXAMPLE
    Enables all rules in the DevRG Resource Group.
    PS C:\scripts>Disable_Enable_AllAlertRulesInRG.ps1 -ResourceGroupName DevRG -Enable
    Date: 02/21/2018
    Blog: http://aka.ms/Theo
    Version: 1.1
#>

[CmdletBinding()]
param (
    # ResourceGroup to operate on.
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    <# Switch parameter to either enable or disable all rules, default value 
        is false if not supplied when calling the script. #>
    [switch]
    $Enable
    )

# Get all the rules for the given Resource Group.
$alertRules = @(Get-AzureRmAlertRule -ResourceGroupName $ResourceGroupName);

<# Function reads the array and disables all rules in the array. If a rule is already disabled,
    it will stay disabled. This is the default function if the -Enable switch is not supplied. #> 
function Disable-AllRules {
    param([string]$RG)
    foreach ($rule in $alertRules) {
        Add-AzureRmMetricAlertRule `
            -ResourceGroupName $RG `
            -TargetResourceId $rule.Condition.DataSource.ResourceUri `
            -Location $rule.Location `
            -Name $rule.AlertRuleResourceName `
            -Description $rule.Description `
            -MetricName $rule.Condition.DataSource.MetricName `
            -Operator $rule.Condition.OperatorProperty `
            -Threshold $rule.Condition.Threshold `
            -WindowSize $rule.Condition.WindowSize `
            -TimeAggregationOperator $rule.Condition.TimeAggregation `
            -DisableRule;
    }
}

<# Function reads the array and enables all rules in the array. If a rule is already enabled,
    it will stay enabled. #> 
function Enable-AllRules {
    param([string]$RG)
    foreach ($rule in $alertRules) {
        Add-AzureRmMetricAlertRule `
            -ResourceGroupName $RG `
            -TargetResourceId $rule.Condition.DataSource.ResourceUri `
            -Location $rule.Location `
            -Name $rule.AlertRuleResourceName `
            -Description $rule.Description `
            -MetricName $rule.Condition.DataSource.MetricName `
            -Operator $rule.Condition.OperatorProperty `
            -Threshold $rule.Condition.Threshold `
            -WindowSize $rule.Condition.WindowSize `
            -TimeAggregationOperator $rule.Condition.TimeAggregation;
    }
}

switch ($Enable) {
    $true { Enable-AllRules -RG $ResourceGroupName; }
    Default { Disable-AllRules -RG $ResourceGroupName; }
}