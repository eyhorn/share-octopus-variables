function Get-SharedVariableNames {
    return @("VariableName1", "VariableName2", "VariableName3")
}

function Set-SharedVariables {
    $variablesToSet = Get-SharedVariableNames
    foreach ($variableName in $variablesToSet) {
        Set-OctopusVariable -name "Shared.$($variableName)" -value $OctopusParameters[$variableName]
    }
}

function Read-SharedVariables {
    $octopusURL = $OctopusParameters["Octopus.Web.BaseUrl"]
    $projectName = "name of the project you a reading variables from"
    $environment = $OctopusParameters["Octopus.Environment.Id"]
    $tenant = $OctopusParameters["Octopus.Deployment.Tenant.Id"]
    $octopusApiKey = "use you Octopus api key"
    $header = @{ "X-Octopus-ApiKey" = octopusApiKey }

    $project = (Invoke-RestMethod $octopusURL/api/projects?name=$projectName -Headers $header -UseBasicParsing).Items | Where-Object Name -eq $projectName
    $getDeploymentUrl = "$($octopusURL)/api/deployments?projects=$($project.Id)&environments=$($environment)&tenants=$($tenant)&taskState=success&take=1"
    $deployment = (Invoke-RestMethod $getDeploymentUrl -Headers $header -UseBasicParsing).Items | Select-Object -first 1
    $variables = (Invoke-RestMethod $octopusURL/api/variables/variableset-$($deployment.Id) -Headers $header -UseBasicParsing).Variables

    $variablesToSet = Get-SharedVariableNames
    foreach ($variableName in $variablesToSet) {
        $variable = $variables | Where-Object Name -Like "*.Output.Shared.$($variableName)" | Select-Object -first 1
        Set-OctopusVariable -name $variableName -value "$($variable.Value)"
    }
  }
