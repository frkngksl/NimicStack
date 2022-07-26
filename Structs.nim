#define MAX_STACK_SIZE 12000
#define RBP_OP_INFO 0x5

const MAX_STACK_SIZE = 12000
const RBP_OP_INFO = 0x5

type
    HelperStackFrame* {.bycopy,packed.} = object
        dllName*:string
        offset*:uint64
        totalStackSize*:uint64
        requiresLoadLibrary*:bool
        setsFramePointer*:bool
        returnAddress*:uint64
        pushRbp*:bool
        countOfCodes*:uint64
        pushRbpIndex*:bool
    