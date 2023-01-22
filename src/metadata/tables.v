module metadata

#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/shared
#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/winrt
#include <roapi.h>
#include <RoMetadataApi.h>
#include <rometadata.h>

const iid_metadata_tables2 = Guid{0xbadb5f70, 0x58da, 0x43a9, [u8(0xa1), 0xc6, 0xd7, 0x48, 0x19,
	0xf1, 0x9b, 0x15]!}

pub struct MetaDataTables {
	tables_ptr &C.IMetaDataTables2
}

pub fn (md MetaDataTables) get_blob(ixBlob u32, pcbData &u32, ppData &&u8) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetBlob(ixBlob, pcbData, ppData)
}

pub fn (md MetaDataTables) get_blob_heap_size(pcbBlobs &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetBlobHeapSize(pcbBlobs)
}

pub fn (md MetaDataTables) get_coded_token_info(ixCdTkn u32, pcTokens &u32, ppTokens &&u32, ppName &string) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetCodedTokenInfo(ixCdTkn, pcTokens, ppTokens, ppName)
}

pub fn (md MetaDataTables) get_column(ixTbl u32, ixCol u32, rid u32, pVal &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetColumn(ixTbl, ixCol, rid, pVal)
}

pub fn (md MetaDataTables) get_column_info(ixTbl u32, ixCol u32, poCol &u32, pcbCol &u32, pType &u32, ppName &string) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetColumnInfo(ixTbl, ixCol, poCol, pcbCol, pType, ppName)
}

pub fn (md MetaDataTables) get_column_info(ixTbl u32, ixCol u32, poCol &u32, pcbCol &u32, pType &u32, ppName &string) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetColumnInfo(ixTbl, ixCol, poCol, pcbCol, pType, ppName)
}

pub fn (md MetaDataTables) get_guid(ixGuix u32, GUID &&u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetGuid(ixGuix, GUID)
}

pub fn (md MetaDataTables) get_guid_heap_size(pcbGuids &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetGuidHeapSize(pcbGuids)
}

pub fn (md MetaDataTables) get_metadata_storage(ppvMd &&u8, pcbMd &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetMetaDataStorage(ppvMd, pcbMd)
}

pub fn (md MetaDataTables) get_metadata_stream_info(ix u32, ppchName &string, ppv &&u8, pcb &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetMetaDataStreamInfo(ix, ppchName, ppv, pcb)
}

pub fn (md MetaDataTables) get_next_blob(ixBlob u32, pNext &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetNextBlob(ixBlob, pNext)
}

pub fn (md MetaDataTables) get_next_guid(ixGuid u32, pNext &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetNextGuid(ixGuid, pNext)
}

pub fn (md MetaDataTables) get_next_string(ixString u32, pNext &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetNextString(ixString, pNext)
}

pub fn (md MetaDataTables) get_next_user_string(ixUserString u32, pNext &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetNextUserString(ixUserString, pNext)
}

pub fn (md MetaDataTables) get_num_tables(pcTables &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetNumTables(pcTables)
}

pub fn (md MetaDataTables) get_row(ixTbl u32, rid u32, ppRow &u8) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetRow(ixTbl, rid, ppRow)
}

pub fn (md MetaDataTables) get_string(ixString u32, ppString &string) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetString(ixString, ppString)
}

pub fn (md MetaDataTables) get_string_heap_size(pcbStrings &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetString(pcbStrings)
}

pub fn (md MetaDataTables) get_table_index(token u32, pixTbl &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetString(token, pixTbl)
}

pub fn (md MetaDataTables) get_table_info(ixTbl u32, pcbRow &u32, pcRows &u32, pcCols &u32, piKey &u32, ppName &string) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetString(ixTbl, pcbRow, pcRows, pcCols, piKey, ppName)
}

pub fn (md MetaDataTables) get_user_string(ixUserString u32, pcbData &u32, ppData &&u8) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetString(ixUserString, pcbData, ppData)
}

pub fn (md MetaDataTables) get_user_string_heap_size(pcbUserStrings &u32) u32 {
	// TODO: Make function idiomatic to V
	md.tables_ptr.lpVtbl.GetString(pcbUserStrings)
}

struct C.IMetaDataTables2 {
	lpVtbl &C.IMetaDataTables2Vtbl
}

struct C.IMetaDataTables2Vtbl {
	// [in] ixBlob
	// The memory address from which to get ppData.
	// [out] pcbData
	// A pointer to the size, in bytes, of ppData.
	// [out] ppData
	// A pointer to a pointer to the binary data retrieved.
	GetBlob fn (ixBlob u32, pcbData &u32, ppData &&u8) u32

	// [out] pcbBlobs
	// A pointer to the size, in bytes, of the BLOB heap.
	GetBlobHeapSize fn (pcbBlobs &u32) u32

	// [in] ixCdTkn
	// The kind of coded token to return.
	// [out] pcTokens
	// A pointer to the length of ppTokens.
	// [out] ppTokens
	// A pointer to a pointer to an array that contains the list of returned tokens.
	// [out] ppName
	// A pointer to a pointer to the name of the token at ixCdTkn.
	GetCodedTokenInfo fn (ixCdTkn u32, pcTokens &u32, ppTokens &&u32, ppName &string) u32

	// [in] ixTbl
	// The index of the table.
	// [in] ixCol
	// The index of the column in the table.
	// [in] rid
	// The index of the row in the table.
	// [out] pVal
	// A pointer to the value in the cell.
	GetColumn fn (ixTbl u32, ixCol u32, rid u32, pVal &u32) u32

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
	GetColumnInfo fn (ixTbl u32, ixCol u32, poCol &u32, pcbCol &u32, pType &u32, ppName &string) u32

	// [in] ixGuid
	// The index of the row from which to get the GUID.
	// [out] ppGUID
	// A pointer to a pointer to the GUID.
	GetGuid fn (ixGuix u32, GUID &&u32) u32

	// [out] pcbGuids
	// A pointer to the size, in bytes, of the GUID heap.
	GetGuidHeapSize fn (pcbGuids &u32) u32

	// [out] ppvMd
	// A pointer to a metadata section.
	// [out] pcbMd
	// The size of the metadata stream.
	GetMetaDataStorage fn (ppvMd &&u8, pcbMd &u32)

	// [in] ix
	// The index of the requested metadata stream.
	// [out] ppchName
	// A pointer to the name of the stream.
	// [out] ppv
	// A pointer to the metadata stream.
	// [out] pcb
	// The size, in bytes, of ppv.
	GetMetaDataStreamInfo fn (ix u32, ppchName &string, ppv &&u8, pcb &u32)

	// [in] ixBlob
	// The index, as returned from a column of BLOBs.
	// [out] pNext
	// A pointer to the index of the next BLOB.
	GetNextBlob fn (ixBlob u32, pNext &u32) u32

	// [in] ixGuid
	// The index value from a GUID table column.
	// [out] pNext
	// A pointer to the index of the next GUID value.
	GetNextGuid fn (ixGuid u32, pNext &u32) u32

	// [in] ixString
	// The index value from a string table column.
	// [out] pNext
	// A pointer to the index of the next string in the column.
	GetNextString fn (ixString u32, pNext &u32) u32

	// [in] ixUserString
	// An index value from the current string column.
	// [out] pNext
	// A pointer to the row index of the next string in the column.
	GetNextUserString fn (ixUserString u32, pNext &u32) u32

	// [out] pcTables
	// A pointer to the number of tables in the current instance scope.
	GetNumTables fn (pcTables &u32) u32

	// [in] ixTbl
	// The index of the table from which the row will be retrieved.
	// [in] rid
	// The index of the row to get.
	// [out] ppRow
	// A pointer to a pointer to the row.
	GetRow fn (ixTbl u32, rid u32, ppRow &u8) u32

	// [in] ixString
	// The index at which to start to search for the next value.
	// [out] ppString
	// A pointer to a pointer to the returned string value.
	GetString fn (ixString u32, ppString &string) u32

	// [out] pcbStrings
	// A pointer to the size, in bytes, of the string heap.
	GetStringHeapSize fn (pcbStrings &u32) u32

	// [in] token
	// The token that references the table.
	// [out] pixTbl
	// A pointer to the returned index for the referenced table.
	GetTableIndex fn (token u32, pixTbl &u32) u32

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
	GetTableInfo fn (ixTbl u32, pcbRow &u32, pcRows &u32, pcCols &u32, piKey &u32, ppName &string) u32

	// [in] ixUserString
	// The index value from which the hard-coded string will be retrieved.
	// [out] pcbData
	// A pointer to the size of ppData.
	// [out] ppData
	// A pointer to a pointer to the returned string.
	GetUserString fn (ixUserString u32, pcbData &u32, ppData &&u8) u32

	// [out] pcbUserStrings
	// A pointer to the size, in bytes, of the user string heap.
	GetUserStringHeapSize fn (pcbUserStrings &u32) u32
}
