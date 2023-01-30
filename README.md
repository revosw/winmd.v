With this project, you can generate bindings to the Windows API for the V programming language.

# Motivation
All useful programs running on Windows eventually require calling into the Windows kernel. This means your program must link to some Windows library at a binary level, and include an associated header file at a source level. To make use of the included structs and functions defined in Windows' C header files, you redeclare these symbols in V.

This is a manual process spanning thousands of structs and functions across the entire Windows API.

# How it works
Microsoft currently uses [ClangSharp](https://github.com/microsoft/win32metadata#clangsharp-overview) to scrape Windows C headers, outputting an `.idl` file in C# (or more specifically, [ecma-335](https://www.ecma-international.org/publications-and-standards/standards/ecma-335/) compliant code). The C# output is then further compiled to a CLR assembly, which is the final step. You now have a `.winmd` file.

Loading and reading winmd files is done with the [metadata API](https://learn.microsoft.com/en-us/windows/win32/api/rometadataapi/). If you're not familiar with COM, please read both the [official documentation](https://learn.microsoft.com/en-us/windows/win32/com/the-component-object-model) and a [deep-dive article on COM in plain C](https://www.codeproject.com/Articles/13601/COM-in-plain-C).

Instead of using `CoCreateInstance` directly, there is a factory function [`MetaDataGetDispenser`](https://learn.microsoft.com/en-us/windows/win32/api/rometadata/nf-rometadata-metadatagetdispenser) we can use to kick things off. With the dispenser, we use `OpenScope` to open a winmd file, specifying either `IID_IMetaDataTables2`, `IID_IMetaDataImport2` or `IID_IMetaDataAssemblyImport`.

`IMetaDataTables` is suitable when you want to store metadata in tables. What this means in practice is 