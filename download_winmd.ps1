if (-not (test-path "WinMetadata") ) {
    # Create folders
    New-Item -Name "WinMetadata" -ItemType "directory"
    New-Item -Name "winmd" -Path "WinMetadata" -ItemType "directory"
    New-Item -Name "json" -Path "WinMetadata" -ItemType "directory"
    
    # # Download and unzip the newest Win32Metadata from NuGet
    Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.Win32Metadata/56.0.13-preview -OutFile win32metadata.zip
    Expand-Archive -Path win32metadata.zip

    # # Copy the existing metadata files from System32
    Copy-Item C:/Windows/System32/WinMetadata/* WinMetadata/winmd/
    Copy-Item win32metadata/Windows.Win32.winmd WinMetadata/winmd/Windows.Win32.winmd

    # Download win32json files
    Invoke-WebRequest -Uri https://api.github.com/repos/marlersoft/win32json/zipball/21.0.3-preview -OutFile win32json.zip
    Expand-Archive -Path win32json.zip

    # Copy json files to WinMetadata
    $jsondir = Get-ChildItem win32json -Filter api -Directory -Recurse
    Copy-Item "$jsondir/*" WinMetadata/json/

    # Remove all zips and extracted files
    Remove-Item win32metadata.zip, win32metadata, win32json.zip, win32json -Recurse
} else {
    echo "WinMetadata already exists. Aborting."
}