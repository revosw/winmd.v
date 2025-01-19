if (-not (test-path "WinMetadata") ) {
    # Create folder
    New-Item -Name "WinMetadata" -ItemType "directory"
    
    # # Download and unzip the newest Win32Metadata from NuGet
    Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.Win32Metadata/56.0.13-preview -OutFile win32metadata.zip
    Expand-Archive -Path win32metadata.zip

    # # Copy the existing metadata files from System32
    Copy-Item C:/Windows/System32/WinMetadata/* WinMetadata/
    Copy-Item win32metadata/Windows.Win32.winmd WinMetadata/Windows.Win32.winmd

    # Remove all zips and extracted files
    Remove-Item win32metadata.zip, win32metadata -Recurse
} else {
    echo "WinMetadata already exists. Aborting."
}