These are notes I jot down when working with the win32json source.

`jq` has been very useful to find the shape and common data of all the constants. For example, in the command below, I iterate over all files in the `WinMetadata/json` directory, and select all constants with `"Kind": "ApiRef"` which are not `"Name": "HRESULT"`. By running this, I can find constants with other data.

```ps1
# Step 1: select all constants where its kind is ApiRef and type.name is not HRESULT
Get-ChildItem -Path .\WinMetadata\json -File | ForEach-Object {
    echo "Checking $($_.FullName)..."
    Get-Content $_.FullName | jq '.Constants[] | select(.Type.Kind == "ApiRef" and .Type.Name != "HRESULT")'
}

# Result: constants with a type.name other than "HRESULT" - for example "PROPERTYKEY".

# Step 2: select all constants where its type.name is not "HRESULT" nor "PROPERTYKEY"
Get-ChildItem -Path .\WinMetadata\json -File | ForEach-Object {
    echo "Checking $($_.FullName)..."
    Get-Content $_.FullName | jq '.Constants[] | select(.Type.Kind == "ApiRef" and .Type.Name != "HRESULT" and .Type.Name != "PROPERTYKEY")'
}

# Result: constants with a type.name other than "HRESULT" nor "PROPERTYKEY" - for example "NTSTATUS".

# Step 3: select all constants where its type.name is not "HRESULT" nor "PROPERTYKEY" nor "NTSTATUS"
Get-ChildItem -Path .\WinMetadata\json -File | ForEach-Object {
    echo "Checking $($_.FullName)..."
    Get-Content $_.FullName | jq '.Constants[] | select(.Type.Kind == "ApiRef" and .Type.Name != "HRESULT" and .Type.Name != "PROPERTYKEY" and .Type.Name != "NTSTATUS")'
}
```

This way, I was able to find that ApiRef may have a type.name of:
- HRESULT
- PROPERTYKEY
- NTSTATUS
- PWSTR
- SOCKET
- HANDLE
- PSTR
- BCRYPT_ALG_HANDLE
- HKEY
- HBITMAP
- HTREEITEM
- DPI_AWARENESS_CONTEXT
- HWND