# Function to prompt user for replacement text
function Get-UserInput {
    $inputText = Read-Host "Enter the replacement text for the fourth row:"
    return $inputText
}

# Get the path to the folder containing the zip files
$folderPath = Read-Host "Enter the path to the folder containing the zip files"

# Get all zip files in the folder
$zipFiles = Get-ChildItem -Path $folderPath -Filter *.zip

# Specify the path to the 7-Zip executable
$7ZipPath = "C:\Program Files\7-Zip\7z.exe"

# Loop through each zip file
foreach ($zipFile in $zipFiles) {
    Write-Host "Processing zip file: $($zipFile.FullName)"

    # Prompt user for password
    $password = Read-Host "Enter the password for $($zipFile.Name)"

    # Search for Import.txt in the zip file
    $importTxtPath = & "$7ZipPath" l -p$password $zipFile.FullName | Where-Object { $_ -match 'Import.txt' } | ForEach-Object { $_ -replace '\s+', ' ' } | Out-Null; $matches[0]

    if ($importTxtPath) {
        Write-Host "Found Import.txt at: $importTxtPath"

        # Prompt user for replacement text
        $replacementText = Get-UserInput

        # Use 7-Zip to update the content of Import.txt in the zip archive
        $updateCommand = "& '$7ZipPath' a -p$password $zipFile.FullName $importTxtPath -si -so"
        $newContent = "$replacementText`r`n" + (& $updateCommand | Out-String)
        $newContent | & "$7ZipPath" u -p$password -si $zipFile.FullName Import.txt
        Write-Host "Replacement completed."
    }
    else {
        Write-Host "Import.txt not found in the zip file."
    }

    Write-Host "-------------------------------------"
}
