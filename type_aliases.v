module main

// These type aliases are named to match the case of their Win32 signatures.
//
// ignore_for_file: camel_case_types

// Type aliases for metadata objects
pub type HCorEnum = &i32;
pub type PcCor_Signature = &u8;
pub type PCor_Signature = &u8;
pub type Uvcp_Constant = &u8;
pub type MdUtf8Cstr = &u8;

// Type aliases for metadata tokens
pub type MdToken = u32;
pub type MdModule = MdToken;
pub type MdTypeRef = MdToken;
pub type MdTypeDef = MdToken;
pub type MdFieldDef = MdToken;
pub type MdMethodDef = MdToken;
pub type MdParamDef = MdToken;
pub type MdInterfaceImpl = MdToken;
pub type MdMemberRef = MdToken;
pub type MdCustomAttribute = MdToken;
pub type MdPermission = MdToken;
pub type MdSignature = MdToken;
pub type MdEvent = MdToken;
pub type MdProperty = MdToken;
pub type MdModuleRef = MdToken;
pub type MdAssembly = MdToken;
pub type MdAssemblyRef = MdToken;
pub type MdFile = MdToken;
pub type MdExportedType = MdToken;
pub type MdManifestResource = MdToken;
pub type MdTypeSpec = MdToken;
pub type MdGenericParam = MdToken;
pub type MdMethodSpec = MdToken;
pub type MdGenericParamConstraint = MdToken;
pub type MdString = MdToken;

