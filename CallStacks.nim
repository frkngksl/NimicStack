import Structs

#[
 SourceImage: C:\Windows\system32\wbem\wmiprvse.exe
 CallTrace:
 C:\Windows\SYSTEM32\ntdll.dll + 9d204
 C:\Windows\System32\KERNELBASE.dll + 2c13e
 C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CorperfmonExt.dll + c669
 C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CorperfmonExt.dll + c71b
 C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CorperfmonExt.dll + 2fde
 C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CorperfmonExt.dll + 2b9e
 C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CorperfmonExt.dll + 2659
 C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CorperfmonExt.dll + 11b6
 C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CorperfmonExt.dll + c144
 C:\Windows\System32\KERNEL32.DLL + 17034
 C:\Windows\SYSTEM32\ntdll.dll + 52651
 NB Don't include first frame as this will automatically be recorded by the syscall in NtOpenProcess
]#


var wmiCallStack*:seq[HelperStackFrame] = @[
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\kernelbase.dll", offset: 0x2c13e, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\CorperfmonExt.dll", offset: 0xc669, totalStackSize: 0, requiresLoadLibrary: true, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\CorperfmonExt.dll", offset: 0xc71b, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\CorperfmonExt.dll", offset: 0x2fde, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\CorperfmonExt.dll", offset: 0x2b9e, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\CorperfmonExt.dll", offset: 0x2659, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\CorperfmonExt.dll", offset: 0x11b6, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\CorperfmonExt.dll", offset: 0xc144, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\kernel32.dll", offset: 0x17034, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\ntdll.dll", offset: 0x52651, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false)
]

#[
SourceImage: C:\Windows\system32\svchost.exe
 CallTrace:
 C:\Windows\SYSTEM32\ntdll.dll + 9d204
 C:\Windows\System32\KERNELBASE.dll + 32ea6
 C:\Windows\System32\lsm.dll + e959
 C:\Windows\System32\RPCRT4.dll + 79633
 C:\Windows\System32\RPCRT4.dll + 13711
 C:\Windows\System32\RPCRT4.dll + dd77b
 C:\Windows\System32\RPCRT4.dll + 5d2ac
 C:\Windows\System32\RPCRT4.dll + 5a408
 C:\Windows\System32\RPCRT4.dll + 3a266
 C:\Windows\System32\RPCRT4.dll + 39bb8
 C:\Windows\System32\RPCRT4.dll + 48a0f
 C:\Windows\System32\RPCRT4.dll + 47e18
 C:\Windows\System32\RPCRT4.dll + 47401
 C:\Windows\System32\RPCRT4.dll + 46e6e
 C:\Windows\System32\RPCRT4.dll + 4b542
 C:\Windows\SYSTEM32\ntdll.dll + 20330
 C:\Windows\SYSTEM32\ntdll.dll + 52f26
 C:\Windows\System32\KERNEL32.DLL + 17034
 C:\Windows\SYSTEM32\ntdll.dll + 52651
]#
var rpcCallStack*:seq[HelperStackFrame] = @[
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\kernelbase.dll", offset: 0x32ea6, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\lsm.dll", offset: 0xe959, totalStackSize: 0, requiresLoadLibrary: true, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x79633, totalStackSize: 0, requiresLoadLibrary: true, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x13711, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0xdd77b, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x5d2ac, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x5a408, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x3a266, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x39bb8, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x48a0f, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x47e18, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x47401, totalStackSize: 0, requiresLoadLibrary: true, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x46e6e, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\RPCRT4.dll", offset: 0x4b542, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\ntdll.dll", offset: 0x20330, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\ntdll.dll", offset: 0x52f26, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\kernel32.dll", offset: 0x17034, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\ntdll.dll", offset: 0x52651, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
]

#[
 SourceImage: C:\Windows\system32\svchost.exe
 CallTrace:
 C:\Windows\SYSTEM32\ntdll.dll + 9d204
 C:\Windows\System32\KERNELBASE.dll + 2c13e
 C:\Windows\system32\sysmain.dll + 80e5f
 C:\Windows\system32\sysmain.dll + 60ce6
 C:\Windows\system32\sysmain.dll + 2a7d3
 C:\Windows\system32\sysmain.dll + 2a331
 C:\Windows\system32\sysmain.dll + 66cf1
 C:\Windows\system32\sysmain.dll + 7b59e
 C:\windows\system32\sysmain.dll + 67ecf
 C:\Windows\system32\svchost.exe + 4300
 C:\Windows\System32\sechost.dll + df78
 C:\Windows\System32\KERNEL32.DLL + 17034
 C:\Windows\SYSTEM32\ntdll.dll + 52651
]#
var svchostCallStack*:seq[HelperStackFrame] = @[
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\kernelbase.dll", offset: 0x2c13e, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\system32\\sysmain.dll", offset: 0x80e5f, totalStackSize: 0, requiresLoadLibrary: true, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\system32\\sysmain.dll", offset: 0x60ce6, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\system32\\sysmain.dll", offset: 0x2a7d3, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\system32\\sysmain.dll", offset: 0x2a331, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\system32\\sysmain.dll", offset: 0x66cf1, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\system32\\sysmain.dll", offset: 0x7b59e, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\system32\\sysmain.dll", offset: 0x67ecf, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\svchost.exe", offset: 0x4300, totalStackSize: 0, requiresLoadLibrary: true, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\sechost.dll", offset: 0xdf78, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\kernel32.dll", offset: 0x17034, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false),
    HelperStackFrame(dllName: "C:\\Windows\\SYSTEM32\\ntdll.dll", offset: 0x52651, totalStackSize: 0, requiresLoadLibrary: false, setsFramePointer: false, returnAddress: 0,pushRbp: false,countOfCodes: 0,pushRbpIndex: false)
]