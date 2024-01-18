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

# Create a temporary folder for extraction
$tempFolder = Join-Path $env:TEMP "ZipImportModifierTemp"

# Loop through each zip file
foreach ($zipFile in $zipFiles) {
    Write-Host "Processing zip file: $($zipFile.FullName)"

    # Prompt user for password
    $password = Read-Host "Enter the password for $($zipFile.Name)"

    # Create a temporary folder for each zip file
    $tempZipFolder = Join-Path $tempFolder $zipFile.BaseName

    # Create the directory if it doesn't exist
    $null = New-Item -ItemType Directory -Force -Path $tempZipFolder

    try {
        # Extract the contents of the zip file using 7-Zip
        $extractCommand = "& '$7ZipPath' e -o'$tempZipFolder' '-p$password' $($zipFile.FullName)"
        Invoke-Expression -Command $extractCommand -ErrorAction Stop

        # Display the extracted files
        Write-Host "Extracted files:"
        Get-ChildItem -Path $tempZipFolder

        # Search for Import.txt in the extracted folder
        $importTxtPath = Get-ChildItem -Path $tempZipFolder -Filter "Import.txt" -Recurse | Select-Object -ExpandProperty FullName

        if ($importTxtPath) {
            Write-Host "Found Import.txt at: $importTxtPath"

            # Read the content of Import.txt
            $content = Get-Content -Path $importTxtPath -Raw

            # Split the content into an array of lines
            $contentArray = $content -split "`n"

            # Check if the array has at least 4 lines
            if ($contentArray.Count -ge 4) {
                # Prompt user for replacement text
                $replacementText = Get-UserInput

                # Modify the specified row (index 3) with the replacement text
                $contentArray[3] = $replacementText

                # Join the array back into a single string with newline characters
                $newContent = $contentArray -join "`n"

                # Write the modified content back to Import.txt
                $newContent | Set-Content -Path $importTxtPath -Force

                Write-Host "Replacement completed."
            }
            else {
                Write-Host "Import.txt does not have enough lines to modify."
            }
        }
        else {
            Write-Host "Import.txt not found in the extracted files."
        }
    }
    catch {
        Write-Host "Error processing zip file $($zipFile.FullName): $_"
    }
    finally {
        # Remove the temporary folder for each zip file
        Remove-Item -Path $tempZipFolder -Recurse -Force
    }

    Write-Host "-------------------------------------"
}
