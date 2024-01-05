# Function to prompt user for replacement text
function Get-UserInput {
    $inputText = Read-Host "Enter the replacement text for the fourth row:"
    return $inputText
}

# Get the path to the folder containing the zip files
$folderPath = Read-Host "Enter the path to the folder containing the zip files"

# Get all zip files in the folder
$zipFiles = Get-ChildItem -Path $folderPath -Filter *.zip

# Loop through each zip file
foreach ($zipFile in $zipFiles) {
    Write-Host "Processing zip file: $($zipFile.FullName)"

    # Prompt user for password
    $password = Read-Host "Enter the password for $($zipFile.Name)"

    try {
        # Try to create a ZipArchive object
        $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zipFile.FullName)

        # Loop through each entry in the zip file
        foreach ($entry in $zipArchive.Entries) {
            try {
                Write-Host "Processing entry: $($entry.FullName)"

                # Try to process the entry
                if ($entry.Name -eq "Import.txt" -and $entry.CompressionMethod -eq "Stored") {
                    $entryStream = $entry.Open()

                    # Skip the first 3 lines
                    for ($i = 0; $i -lt 3; $i++) {
                        $entryStream.ReadLine() | Out-Null
                    }

                    # Get user input for replacement text
                    $replacementText = Get-UserInput

                    Write-Host "Replacing the fourth row with: $replacementText"

                    # Set the position to the beginning of the stream
                    $entryStream.Position = 0

                    # Skip the first 3 lines again
                    for ($i = 0; $i -lt 3; $i++) {
                        $entryStream.ReadLine() | Out-Null
                    }

                    # Write the replacement text to the stream
                    $entryStream.Write([System.Text.Encoding]::UTF8.GetBytes($replacementText), 0, $replacementText.Length)

                    Write-Host "Replacement completed."

                    # Close the entry stream
                    $entryStream.Close()
                }
                else {
                    Write-Host "Skipping entry: Unsupported compression method or not named 'Import.txt'"
                }
            }
            catch {
                Write-Host "Error processing entry $($entry.Name): $_"
            }
        }
    }
    catch {
        Write-Host "Error opening zip file $($zipFile.FullName): $_"
    }
    finally {
        # Close the ZipArchive if it was successfully opened
        if ($zipArchive -ne $null) {
            $zipArchive.Dispose()
        }
    }

    Write-Host "-------------------------------------"
}
