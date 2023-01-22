module winmd

// These type aliases are named to match the case of their Win32 signatures.
//
// ignore_for_file: camel_case_types

// Type aliases for metadata objects
pub type HCorEnum = &int
pub type PcCor_Signature = &u8
pub type PCor_Signature = &u8
pub type Uvcp_Constant = &u8
pub type MdUtf8Cstr = &u8

// Type aliases for metadata tokens
pub type MdToken = u32
pub type MdModule = u32
pub type MdTypeRef = u32
pub type MdTypeDef = u32
pub type MdFieldDef = u32
pub type MdMethodDef = u32
pub type MdParamDef = u32
pub type MdInterfaceImpl = u32
pub type MdMemberRef = u32
pub type MdCustomAttribute = u32
pub type MdPermission = u32
pub type MdSignature = u32
pub type MdEvent = u32
pub type MdProperty = u32
pub type MdModuleRef = u32
pub type MdAssembly = u32
pub type MdAssemblyRef = u32
pub type MdFile = u32
pub type MdExportedType = u32
pub type MdManifestResource = u32
pub type MdTypeSpec = u32
pub type MdGenericParam = u32
pub type MdMethodSpec = u32
pub type MdGenericParamConstraint = u32
pub type MdString = u32

