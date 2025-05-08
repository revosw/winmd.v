With this project, you can generate bindings to the Windows API for the V programming language.

# Setting up
Before you run `v run .`, you will need to run the `./setup.ps1` script. The script will:
1. Download [Microsoft.Windows.SDK.Win32Metadata from nuget](https://www.nuget.org/packages/Microsoft.Windows.SDK.Win32Metadata/), unpack it, move the `.winmd` file out of the extracted folder, and delete the zip file
2. Download [Microsoft.Windows.SDK.Win32Docs from nuget](https://www.nuget.org/packages/Microsoft.Windows.SDK.Win32Docs/), unpack it, move the `apidocs.msgpack` file out of the extracted folder, and delete the zip file
3. Generate a JSON file from the msgpack file using python. I have yet to figure out how to use the V implementation of [msgpack](https://vpm.vlang.io/packages/msgpack) for this, so that I can skip the conversion to JSON.

You can now run `v run .` to build the projection.

# Viewing the metadata
There are two ways to view the metadata. One is to view the raw binary contents of the Windows.Win32.winmd file. The other is to use ILSpy.

## Viewing as raw binary data
This was useful for when I implemented the winmd reader. I could cross-reference with ILSpy to see exactly which field came in which order when parsing tables. It's becoming less relevant now that the program is able to read many of the tables and heaps correctly.

If you use VS Code, you may install the [Hex Editor extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.hexeditor) Click the winmd file that was downloaded by the setup script, and open the file using the installed hex editor extension. You may set hex editor as the default extension to handle winmd files so that you don't have to choose every time.

## Viewing using ILSpy
[ILSpy](https://github.com/icsharpcode/ILSpy) is a tool for disassembling .NET assemblies. Normally .NET assemblies contain both metadata and CIL. The metadata describes all the classes, interfaces, events, delegates, attributes and other types that exist in the assembly. The CIL, or common intermediate language, are the instructions that the .NET runtime executes when running methods. Although ILSpy can disassemble both metadata and CIL, Windows.Win32.winmd contains purely metadata. It's a great way to quickly check which type a parameter has or similar.

After downloading ILSpy, click File in the top left and then Open. Open Windows.Win32.winmd. It will load the assembly. Expand, and you'll find Metadata.

# Motivation
All useful programs running on Windows eventually require calling into the Windows kernel. This means your program must link to some Windows library at a binary level, and include an associated C header file at a source level. To make use of the included structs and functions defined in Windows' C header files, you must redeclare these symbols in a `.v.c` file.

This is a manual process spanning thousands of structs and functions across the entire Windows API. Automating this collectively saves an enormous amount of manual labor across the V ecosystem.

# What's the goal?
The goal is to generate a projection of the Windows API for the V programming language. Let's break down what it means.

Let's say you want to call `CreateFile` from the Windows API. Calling an external API means three things:

**You need to know which library the function is in**. The Windows API is grouped into multiple libraries. For example, `CreateFile` is in the `kernel32` library. If you scroll all the way down to the requirements section of `CreateFileA`'s [documentation page](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilea#requirements), you can see that it's in the `Kernel32.dll` library. This means in order to use `CreateFile`, you will need to link to `kernel32` when building your application. You can do this using the `#flag -l` directive in your `main.c.v` file.
```v
module main

#flag -lkernel32

// When building your V program, the C backend will emit
// these functions as declarations. When compiling the
// resulting C file, the linker will pick these
// up and try to resolve them to their definition.
fn C.CreateFileA(...)
fn C.CreateFileW(...)
```
Great, the linker resolved the function, so your program knows exactly which dll file it should load, and at which address in the dll it can find the function. But you need to know how to call it. In other words...

**You need to know the [calling convention](https://en.wikipedia.org/wiki/Calling_convention)**. If you look in the header files of `fileapi.h` The calling convention is documented between the return type and the function name. In the case of CreateFileA it's `WINAPI`, which is a macro that expands to `__stdcall`.
```c
WINBASEAPI
HANDLE
WINAPI
CreateFileA(
    _In_ LPCSTR lpFileName,
    _In_ DWORD dwDesiredAccess,
    _In_ DWORD dwShareMode,
    _In_opt_ LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    _In_ DWORD dwCreationDisposition,
    _In_ DWORD dwFlagsAndAttributes,
    _In_opt_ HANDLE hTemplateFile
    );
```

- **You need to know how many parameters there are, the size in bytes of each parameter and the size in bytes of the return type**. 

Once we know all these three things, we can properly call functions in the Windows API by linking to the library they exist in, then passing the right arguments to it using the correct calling convention.

# Why not use win32json?
win32json is a fantastic way to generate language projections. Instead of either writing a winmd parser from scratch, or using C#'s System.Reflection.Metadata, the entire pipeline can be implemented in the host language very quickly.

My goal reaches further than just generating bindings for the Windows API. I plan on taking the knowledge I gain from this project to dive deeper into the ECMA-335 specification, and research a possible .NET backend for V.

The other alternative is to parse the [winmd files](https://www.nuget.org/packages/Microsoft.Windows.SDK.Win32Metadata) generated by [win32metadata](https://github.com/microsoft/win32metadata).

## Why not use the metadata API?
The [metadata API](https://learn.microsoft.com/en-us/windows/win32/api/rometadataapi/) may be used for loading and parsing winmd files. However, this ties the generator to Windows only. It's nice being able to run the generator on all platforms. This enables the package to perhaps one day be a part of [V's CI pipeline](https://github.com/vlang/v/actions)

# What is a winmd file?
Microsoft currently uses [ClangSharp](https://github.com/microsoft/win32metadata#clangsharp-overview) to scrape Windows C headers, outputting an `.idl` file. The idl file describes every detail about types and functions. It can be transformed into C#, then further compiled into a common language runtime (CLR) assembly, which is the final step. You now have a `.winmd` file.

# Roadmap
Check the [milestones](https://github.com/revosw/winmd.v/milestones). I'll try to update the milestones with new issues to reflect the progress. 

# Further reading
- [Anatomy of a .NET Assembly – CLR metadata 1](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-clr-metadata-1/)
- [Anatomy of a .NET Assembly – CLR metadata 2](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-clr-metadata-2/)
- [Anatomy of a .NET Assembly – CLR metadata 3](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-clr-metadata-3/)
- [Anatomy of a .NET Assembly – Methods](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-methods/)
- [Anatomy of a .NET Assembly – PE Headers](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-pe-headers/)
- [Anatomy of a .NET Assembly – Signature encodings](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-signature-encodings/)
- [Anatomy of a .NET Assembly – Custom attribute encoding](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-custom-attribute-encoding/)
- [Anatomy of a .NET Assembly – Type forwards](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-type-forwards/)
- [Anatomy of a .NET Assembly – The CLR Loader stub](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-the-clr-loader-stub/)
- [Anatomy of a .NET Assembly – The DOS stub](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-the-dos-stub/)