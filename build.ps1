# &{Import-Module @"
# C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll
# "@; Enter-VsDevShell 913dd44f}; cd /dev/v/winmd; `
v -o bin/main.c -cc msvc .; cl bin\main.c /Fo"bin\" /Fe"bin\" /Fd"bin\" /MDd -I "C:\dev\_tools\v\thirdparty\cJSON" "C:\dev\_tools\v/thirdparty/cJSON/cJSON.obj" /link runtimeobject.lib rometadata.lib advapi32.lib /debug:full
