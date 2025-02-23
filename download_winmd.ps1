if (-not (test-path "Windows.Win32.winmd") ) {
    # # Download and unzip the newest Win32Metadata from NuGet
    Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.Win32Metadata/63.0.31-preview -OutFile win32metadata.zip
    Expand-Archive -Path win32metadata.zip

    # # Copy the existing metadata files from System32
    Copy-Item win32metadata/Windows.Win32.winmd Windows.Win32.winmd

    # Remove all zips and extracted files
    Remove-Item win32metadata.zip, win32metadata -Recurse
} else {
    echo "WinMetadata already exists. Aborting."
}