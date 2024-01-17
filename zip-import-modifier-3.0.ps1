# Set the path to the directory containing zip files
$sourceDirectory = Read-Host "Enter the path to the directory containing zip files"
$password = Read-Host "Enter the password for zip files"
$rowNumberToModify = Read-Host "Enter the row number to modify"
$newContentForRow = Read-Host "Enter the new content for the specific row"

# Full path to 7-Zip executable
$7ZipExecutablePath = "C:\Program Files\7-Zip\7z.exe"  # Update with your actual path

# Check if 7-Zip executable exists
if (Test-Path $7ZipExecutablePath) {
    # Check if the source directory exists
    if (Test-Path $sourceDirectory -PathType Container) {
        # Get all zip files in the source directory
        $zipFiles = Get-ChildItem -Path $sourceDirectory -Filter *.zip

        foreach ($zipFile in $zipFiles) {
            # Create a temporary file for modified content
            $tempModifiedFile = [System.IO.Path]::GetTempFileName()

            try {
                # Extract the specified file to the temporary modified file using 7-Zip
                & $7ZipExecutablePath e "-o$sourceDirectory" "-p$password" "$($zipFile.FullName)" "*Import.txt" -so | ForEach-Object {
                    # Process each line and modify the specific row
                    $_ -replace "^.*$rowNumberToModify.*$", $newContentForRow
                } | Out-File -FilePath $tempModifiedFile -Force -Encoding UTF8

                # Update the zip file with the modified content
                & $7ZipExecutablePath u "-o$sourceDirectory" "-p$password" "$($zipFile.FullName)" "$tempModifiedFile" -r
            } finally {
                # Remove the temporary modified file
                Remove-Item -Path $tempModifiedFile -Force
            }
        }

        Write-Host "Modification completed for all files."
    } else {
        Write-Host "Source directory not found: $sourceDirectory"
    }
} else {
    Write-Host "7-Zip executable not found. Please provide the correct path to 7z.exe."
}
