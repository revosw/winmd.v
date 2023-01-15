module com
#include ...

// [in] ixBlob
// The memory address from which to get ppData.
// [out] pcbData
// A pointer to the size, in bytes, of ppData.
// [out] ppData
// A pointer to a pointer to the binary data retrieved.
fn C.GetBlob(ixBlob u32, pcbData &u32, ppData &&u8) u32

// [out] pcbBlobs
// A pointer to the size, in bytes, of the BLOB heap.
fn C.GetBlobHeapSize(pcbBlobs &u32) u32

// [in] ixCdTkn
// The kind of coded token to return.
// [out] pcTokens
// A pointer to the length of ppTokens.
// [out] ppTokens
// A pointer to a pointer to an array that contains the list of returned tokens.
// [out] ppName
// A pointer to a pointer to the name of the token at ixCdTkn.
fn C.GetCodedTokenInfo(ixCdTkn u32, pcTokens &u32, ppTokens &&u32, ppName &string) u32

// [in] ixTbl
// The index of the table.
// [in] ixCol
// The index of the column in the table.
// [in] rid
// The index of the row in the table.
// [out] pVal
// A pointer to the value in the cell.
fn C.GetColumn(ixTbl u32, ixCol u32, rid u32, pVal &u32) u32

// [in] ixTbl
// The index of the desired table.
// [in] ixCol
// The index of the desired column.
// [out] poCol
// A pointer to the offset of the column in the row.
// [out] pcbCol
// A pointer to the size, in bytes, of the column.
// [out] pType
// A pointer to the type of the values in the column.
// [out] ppName
// A pointer to a pointer to the column name.
fn C.GetColumnInfo(ixTbl u32, ixCol u32, poCol &u32, pcbCol &u32, pType &u32, ppName &string) u32

// [in] ixGuid
// The index of the row from which to get the GUID.
// [out] ppGUID
// A pointer to a pointer to the GUID.
fn C.GetGuid(ixGuix u32, GUID &&u32) u32

// [out] pcbGuids
// A pointer to the size, in bytes, of the GUID heap.
fn C.GetGuidHeapSize(pcbGuids &u32) u32

// [in] ixBlob
// The index, as returned from a column of BLOBs.
// [out] pNext
// A pointer to the index of the next BLOB.
fn C.GetNextBlob(ixBlob u32, pNext &u32) u32

// [in] ixGuid
// The index value from a GUID table column.
// [out] pNext
// A pointer to the index of the next GUID value.
fn C.GetNextGuid(ixGuid u32, pNext &u32) u32

// [in] ixString
// The index value from a string table column.
// [out] pNext
// A pointer to the index of the next string in the column.
fn C.GetNextString(ixString u32, pNext &u32) u32

// [in] ixUserString
// An index value from the current string column.
// [out] pNext
// A pointer to the row index of the next string in the column.
fn C.GetNextUserString(ixUserString u32, pNext &u32) u32

// [out] pcTables
// A pointer to the number of tables in the current instance scope.
fn C.GetNumTables(pcTables &u32) u32

// [in] ixTbl
// The index of the table from which the row will be retrieved.
// [in] rid
// The index of the row to get.
// [out] ppRow
// A pointer to a pointer to the row.
fn C.GetRow(ixTbl u32, rid u32, ppRow &u8) u32

// [in] ixString
// The index at which to start to search for the next value.
// [out] ppString
// A pointer to a pointer to the returned string value.
fn C.GetString(ixString u32, ppString &string) u32

// [out] pcbStrings
// A pointer to the size, in bytes, of the string heap.
fn C.GetStringHeapSize(pcbStrings &u32) u32

// [in] token
// The token that references the table.
// [out] pixTbl
// A pointer to the returned index for the referenced table.
fn C.GetTableIndex(token u32, pixTbl &u32) u32

// [in] ixTbl
// The identifier of the table whose properties to return.
// [out] pcbRow
// A pointer to the size, in bytes, of a table row.
// [out] pcRows
// A pointer to the number of rows in the table.
// [out] pcCols
// A pointer to the number of columns in the table.
// [out] piKey
// A pointer to the index of the key column, or -1 if the table has no key column.
// [out] ppName
// A pointer to a pointer to the table name.
fn C.GetTableInfo(ixTbl u32, pcbRow &u32, pcRows &u32, pcCols &u32, piKey &u32, ppName &string) u32

// [in] ixUserString
// The index value from which the hard-coded string will be retrieved.
// [out] pcbData
// A pointer to the size of ppData.
// [out] ppData
// A pointer to a pointer to the returned string.
fn C.GetUserString(ixUserString u32, pcbData &u32, ppData &&u8) u32

// [out] pcbUserStrings
// A pointer to the size, in bytes, of the user string heap.
fn C.GetUserStringHeapSize(pcbUserStrings &u32) u32
