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

proc CalculateStackSize(pRuntimeFunction:PRUNTIME_FUNCTION,imageBase:DWORD64,indexToStackFrame:int):bool = 
    var returnValue:bool = true
    return returnValue

proc CalculateStackSizeWrapper(indexToStackFrame:int):bool = 
    var returnValue:bool = false
    var pRuntimeFunction:PRUNTIME_FUNCTION = nil
    var pHistoryTable:PUNWIND_HISTORY_TABLE = nil
    var imageBase:DWORD64 = 0
    if(selectedStackFrame[indexToStackFrame].returnAddress == 0):
        return returnValue
    pRuntimeFunction = RtlLookupFunctionEntry(cast[DWORD64](selectedStackFrame[indexToStackFrame].returnAddress), addr(imageBase),pHistoryTable)
    if(pRuntimeFunction == nil):
        return returnValue
    returnValue = CalculateStackSize(pRuntimeFunction,imageBase,indexToStackFrame)
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
        if(not CalculateStackSizeWrapper(seqIndex)):
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
