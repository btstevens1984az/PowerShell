# Purpose: default.tests — Cross-cutting logging, error handling, and utilities.
# describes the function {0}
Describe '{0}' {

  # scenario 1: call the function without arguments
  Context 'Running without arguments'   {
    # test 1: it does not throw an exception:
    It 'runs without errors' {
      # Gotcha: to use the "Should Not Throw" assertion,
      # make sure you place the command in a 
      # scriptblock (braces):
      { {0} } | Should Not Throw
    }
    It 'does something' {
      # call function {0} and pipe the result to an assertion
      # Example:
      # {0} | Should Be 'Expected Output'
      # Hint: 
      # Once you typed "Should", press CTRL+J to see
      # available code snippets. You can also click anywhere
      # inside a "Should" and press CTRL+J to change assertion.
      # However, make sure the module "Pester" is
      # loaded to see the snippets. If the module is not loaded yet,
      # no snippets will show.
    }
    # test 2: it returns nothing ($null):
    It 'does not return anything'     {
      {0} | Should BeNullOrEmpty 
    }
  }
}
