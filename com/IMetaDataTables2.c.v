module com

// [out] ppvMd
// A pointer to a metadata section.
// [out] pcbMd
// The size of the metadata stream.
fn C.GetMetaDataStorage(ppvMd &&u8, pcbMd &u32)


// [in] ix
// The index of the requested metadata stream.
// [out] ppchName
// A pointer to the name of the stream.
// [out] ppv
// A pointer to the metadata stream.
// [out] pcb
// The size, in bytes, of ppv.
fn C.GetMetaDataStreamInfo(ix u32, ppchName &string, ppv &&u8, pcb &u32)
