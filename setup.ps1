if (-not (test-path "Windows.Win32.winmd") ) {
    echo "Downloading Windows.Win32.winmd from nuget"
    # # Download and unzip the newest Win32Metadata from NuGet
    Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.Win32Metadata/63.0.31-preview -OutFile win32metadata.zip
    Expand-Archive -Path win32metadata.zip

    # # Copy the existing metadata files from System32
    Copy-Item win32metadata/Windows.Win32.winmd Windows.Win32.winmd

    # Remove all zips and extracted files
    Remove-Item win32metadata.zip, win32metadata -Recurse
} else {
    echo "Windows.Win32.winmd already exists. Doing nothing."
}

if (-not (test-path "apidocs.msgpack") ) {
    echo "Downloading apidocs.msgpack from nuget"
    # # Download and unzip the newest Win32Metadata from NuGet
    Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.Win32Docs/0.1.42-alpha -OutFile win32docs.zip
    Expand-Archive -Path win32docs.zip

    # # Copy the existing metadata files from System32
    Copy-Item win32docs/apidocs.msgpack apidocs.msgpack

    # Remove all zips and extracted files
    Remove-Item win32docs.zip, win32docs -Recurse
} else {
    echo "apidocs.msgpack already exists. Doing nothing."
}

if (-not (test-path "apidocs.json") ) {
    echo "Converting apidocs.msgpack to apidocs.json"
    [System.IO.File]::ReadAllBytes("./apidocs.msgpack") | python -c "import sys, msgpack, json; unpacker = msgpack.Unpacker(sys.stdin.buffer, raw=False); print(json.dumps([obj for obj in unpacker], indent=2))" | Set-Content "./apidocs.json"
} else {
    echo "apidocs.json already exists. Doing nothing."
}