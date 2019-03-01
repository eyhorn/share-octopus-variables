# Share Octopus Deploy variables between projects

There is no straightforward way to use transformed variables from one project in another project in [Octopus Deploy](https://octopus.com/).
The solution is to use Octopus API.

## Variable sharing guide

1. In the library create script module `ShareVariables` using content of the shareProjectVariablesModule.ps1 as the body for the module
2. In the source project:
   1. Include script module `ShareVariables`
   2. Add a script step `Set Shared Variables`
   3. As a script body use `Set-SharedVariables`
3. In the target deployment project
   1. Include script module `ShareVariables`
   2. For each step that requires shared variables:
      1. Enable `Custom Deployment scripts` in [Configuration features](https://octopus.com/docs/deployment-process/configuration-features)
      2. In the `Pre-deployment script` set the body of the script to `Read-SharedVariables`

## Configuration of the script module

In the `ShareVariables` script module set:

1. In the function `Get-SharedVariableNames` provide names of the variables that require sharing
2. In the function `Read-SharedVariables`:
   1. Set `$projectName` to the name of project you are reading variables from
   2. Set `$octopusApiKey` to the [Api key](https://octopus.com/docs/api-and-integration/api/how-to-create-an-api-key) that you have created

If you do not use tenants in your deployments you might need to remove `tenant` url parameter from the `$getDeploymentUrl`