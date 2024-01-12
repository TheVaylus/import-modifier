
# Prompt the user for input
$sourceDirectory = Read-Host "Enter the path to the directory containing zip files"
$tempFolder = Read-Host "Enter the path to the temporary folder"
$password = Read-Host "Enter the password for zip files"
$rowNumberToModify = Read-Host "Enter the row number to modify"
$newContentForRow = Read-Host "Enter the new content for the specific row"

# Full path to 7-Zip executable
$7ZipExecutablePath = "C:\Program Files\7-Zip\7z.exe"

if (Test-Path $7ZipExecutablePath) {
    # Check if the source directory exists
    if (Test-Path $sourceDirectory -PathType Container) {
        # Get all zip files in the source directory
        $zipFiles = Get-ChildItem -Path $sourceDirectory -Filter *.zip

        foreach ($zipFile in $zipFiles) {
            # Create the temporary folder if it doesn't exist
            $destination = Join-Path $tempFolder $zipFile.BaseName
            if (-not (Test-Path $destination -PathType Container)) {
                New-Item -ItemType Directory -Path $destination | Out-Null
            }

            # Extract each password-protected zip file to the temporary folder using 7-Zip
            & $7ZipExecutablePath x "-o$destination" "-p$password" "$($zipFile.FullName)" -y
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error extracting '$zipFile.FullName'. Check the password or other issues."
            } else {
                Write-Host "Successfully extracted '$zipFile.FullName'."

                # Check for the existence of the "Import" file in the extracted folder
                $importFile = Join-Path $destination "Import.txt"
                if (Test-Path $importFile) {
                    Write-Host "Found 'Import' file in '$zipFile'. Modifying content."

                    # Read the existing content of the "Import.txt" file
                    $existingContent = Get-Content -Path $importFile

                    # Modify the specific row
                    $existingContent[$rowNumberToModify - 1] = $newContentForRow

                    # Write the updated content back to the file
                    $existingContent | Set-Content -Path $importFile
                } else {
                    Write-Host "No 'Import' file found in '$zipFile'."
                }

                # Create a new folder for temporary storage of modified files
                $tempModifiedFolder = Join-Path $tempFolder "ModifiedFiles"
                New-Item -ItemType Directory -Path $tempModifiedFolder | Out-Null

                # Move the modified files to the new folder
                Move-Item -Path "$($destination)\*" -Destination $tempModifiedFolder -Force

                # Zip the modified files back into a new zip file using 7-Zip with the same password
                $outputZip = Join-Path $tempFolder "$($zipFile.BaseName).zip"
                & $7ZipExecutablePath a -tzip "-p$password" "$outputZip" "$tempModifiedFolder\*" -mx=9
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Created new zip file: $outputZip"
                } else {
                    Write-Host "Error creating new zip file: $outputZip"
                }

                # Clean up: remove the temporary folders
                Remove-Item -Path $destination -Recurse -Force
                Remove-Item -Path $tempModifiedFolder -Recurse -Force
            }
        }

        Write-Host "Unzipping and zipping completed using 7-Zip with password for all files."
    } else {
        Write-Host "Source directory not found: $sourceDirectory"
    }
} else {
    Write-Host "7-Zip executable not found. Please provide the correct path to 7z.exe."
}