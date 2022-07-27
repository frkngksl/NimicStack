import winim
import ptr_math
import system
import os
import tables
import Structs
import CallStacks

var selectedStackFrame:seq[HelperStackFrame] = @[]
var dllAddressMap = initTable[string, uint64]()

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
                    selectedStackFrame[indexToStackFrame].countOfCodes = pUnwindInfo.countOfCodes
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

when isMainModule:
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
