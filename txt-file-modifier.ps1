# Specify the input file path and output file path
$inputFilePath = "C:\Users\esjimenez\Desktop\test"
$outputFilePath = "C:\Users\esjimenez\Desktop"

# Specify the pattern to match
$pattern = "Set C_AccountNum = '\d+'"

# Read the content of the input file
$content = Get-Content -Path $inputFilePath

# Iterate through each line and replace the specified part
foreach ($line in $content) {
    $modifiedLine = $line -replace $pattern, "Set C_AccountNum = NULL"
    $modifiedContent += $modifiedLine
}

# Save the modified content back to the output file
$modifiedContent | Out-File -FilePath $outputFilePath -Force

Write-Host "Script executed successfully. Output saved to $outputFilePath"
