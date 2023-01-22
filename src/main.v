module main

#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/shared
#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/winrt
#flag -lruntimeobject
#flag -lrometadata
#include <roapi.h>
#include <RoMetadataApi.h>
#include <rometadata.h>

// EXTERN_GUID(CLSID_CorMetaDataDispenser, 0xe5cb7a31, 0x7512, 0x11d2, 0x89, 0xce, 0x0, 0x80, 0xc7, 0x92, 0xe5, 0xd8);
// EXTERN_GUID(IID_IMetaDataDispenser, 0x809c652e, 0x7396, 0x11d2, 0x97, 0x71, 0x00, 0xa0, 0xc9, 0xb4, 0xd5, 0x0c);
// EXTERN_GUID(IID_IMetaDataDispenserEx, 0x31bcfce2, 0xdafb, 0x11d2, 0x9f, 0x81, 0x0, 0xc0, 0x4f, 0x79, 0xa0, 0xa3);
// EXTERN_GUID(IID_IMetaDataAssemblyImport, 0xee62470b, 0xe94b, 0x424e, 0x9b, 0x7c, 0x2f, 0x0, 0xc9, 0x24, 0x9f, 0x93);
// EXTERN_GUID(IID_IMetaDataImport, 0x7dac8207, 0xd3ae, 0x4c75, 0x9b, 0x67, 0x92, 0x80, 0x1a, 0x49, 0x7d, 0x44);
// EXTERN_GUID(IID_IMetaDataImport2, 0xfce5efa0, 0x8bba, 0x4f8e, 0xa0, 0x36, 0x8f, 0x20, 0x22, 0xb0, 0x84, 0x66);
// EXTERN_GUID(IID_IMetaDataTables, 0xd8f579ab, 0x402d, 0x4b8e, 0x82, 0xd9, 0x5d, 0x63, 0xb1, 0x6, 0x5c, 0x68);
// EXTERN_GUID(IID_IMetaDataTables2, 0xbadb5f70, 0x58da, 0x43a9, 0xa1, 0xc6, 0xd7, 0x48, 0x19, 0xf1, 0x9b, 0x15);

struct Guid {
	data1 u32
	data2 u16
	data3 u16
	data4 [8]u8
}

const (
	clsid_metadata_dispenser = Guid{0xe5cb7a31, 0x7512, 0x11d2, [u8(0x89), 0xce, 0x0, 0x80, 0xc7, 0x92,
	0xe5, 0xd8]!}
	iid_metadata_dispenser = Guid{0x809c652e, 0x7396, 0x11d2, [u8(0x97), 0x71, 0x0, 0xa0, 0xc9, 0xb4,
	0xd5, 0x0c]!}
	iid_metadata_import = Guid{0x809c652e, 0x7396, 0x11d2, [u8(0x97), 0x71, 0x0, 0xa0, 0xc9, 0xb4,
0xd5, 0x0c]!}
)
struct iid {
	metadata_import Guid = Guid{0x809c652e, 0x7396, 0x11d2, [u8(0x97), 0x71, 0x0, 0xa0, 0xc9, 0xb4,
	0xd5, 0x0c]!}
}

struct C.IMetaDataDispenser {
	lpVtbl &C.IMetaDataDispenserVtbl
}

struct C.IMetaDataDispenserVtbl {
	OpenScope fn (&C.IMetaDataDispenser, &u16, int, &Guid, &C.IMetaDataImport) u32
}

struct C.IMetaDataImport {
	lpVtbl &C.IMetaDataImportVtbl
}

struct C.IMetaDataImportVtbl {
	OpenScope fn (&C.IMetaDataImport, &u16, int, &Guid, &C.IMetaDataImport) u32
}

struct MetadataDispenser {
	clsid         Guid = Guid{0xe5cb7a31, 0x7512, 0x11d2, [u8(0x89), 0xce, 0x0, 0x80, 0xc7, 0x92,
	0xe5, 0xd8]!}
	iid           Guid = Guid{0x809c652e, 0x7396, 0x11d2, [u8(0x97), 0x71, 0x0, 0xa0, 0xc9, 0xb4,
	0xd5, 0x0c]!}
	dispenser_ptr &C.IMetaDataDispenser = 0
	import_ptr    &C.IMetaDataImport    = 0
}

struct MetadataImport {
	iid Guid = Guid{0x7dac8207, 0xd3ae, 0x4c75, [u8(0x9b), 0x67, 0x92, 0x80, 0x1a, 0x49, 0x7d, 0x44]!}
}

fn (md MetadataDispenser) open_scope() {
	iid_metadata_import := Guid{0x7dac8207, 0xd3ae, 0x4c75, [u8(0x9b), 0x67, 0x92, 0x80, 0x1a,
		0x49, 0x7d, 0x44]!}
	a := md.dispenser_ptr.lpVtbl.OpenScope(md.dispenser_ptr, 'C:/Windows/System32/WinMetadata/Windows.Foundation.winmd'.to_wide(),
		0, &iid_metadata_import, &md.import_ptr)
}

enum RoInitType {
	singlethreaded
	multithreaded
}

fn C.RoInitialize(RoInitType) u32

[callconv: 'stdcall']
fn C.MetaDataGetDispenser(clsid &Guid, iid &Guid, dispenser_ptr_ptr &&C.IMetaDataDispenser) u32

fn main() {
	if C.RoInitialize(RoInitType.singlethreaded) != 0 {
		panic('Out of memory or something, idk')
	}
	dispenser := get_metadata_dispenser()
	dispenser.open_scope()
}

fn get_metadata_dispenser() MetadataDispenser {
	mut dispenser := MetadataDispenser{}
	hresult := C.MetaDataGetDispenser(&dispenser.clsid, &dispenser.iid, &dispenser.dispenser_ptr)
	match hresult {
		0x80004002 {
			println("The dispenser doesn't support this interface")
		}
		else {}
	}

	return dispenser
}
