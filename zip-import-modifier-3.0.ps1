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

    # Use 7-Zip to update the content of Import.txt in the zip archive
    $importTxtPath = "Import.txt"
    $replacementText = Get-UserInput

    # Create a temporary file to hold the replacement text
    $tempFile = [System.IO.Path]::GetTempFileName()
    $replacementText | Set-Content -Path $tempFile -Force

    $updateCommand = "& '$7ZipPath' a -p$password $zipFile.FullName $tempFile -si -so"
    & $updateCommand | & "$7ZipPath" u -p$password -si $zipFile.FullName $importTxtPath

    Remove-Item -Path $tempFile -Force

    Write-Host "Replacement completed."

    Write-Host "-------------------------------------"
}
