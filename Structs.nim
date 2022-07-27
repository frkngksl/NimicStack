#define MAX_STACK_SIZE 12000
#define RBP_OP_INFO 0x5

const MAX_STACK_SIZE* = 12000
const RBP_OP_INFO* = 0x5

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
        pushRbpIndex*:int
    
    #[
   typedef union _UNWIND_CODE {
	struct {
		unsigned char CodeOffset;
		unsigned char UnwindOp : 4;
		unsigned char OpInfo : 4;
	};
	unsigned short FrameOffset;
    } UNWIND_CODE, *PUNWIND_CODE;
    ]#
    INNER_UNWIND_CODESTRUCT {.bycopy, packed.} = object
        codeOffset*: uint8
        unwindOp* {.bitsize: 4.}: uint8
        opInfo* {.bitsize: 4.}: uint8
    
    UNWIND_CODE* {.bycopy,packed, union.} = object
        innerStruct*: INNER_UNWIND_CODESTRUCT
        frameOffset*: cushort
    #[
    typedef struct _UNWIND_INFO {
	unsigned char Version : 3;
	unsigned char Flags : 5;
	unsigned char SizeOfProlog;
	unsigned char CountOfCodes;
	unsigned char FrameRegister : 4;
	unsigned char FrameOffset : 4;
	UNWIND_CODE UnwindCode[1];
    } UNWIND_INFO, * PUNWIND_INFO;
    ]#

    UNWIND_INFO* {.bycopy,packed.} = object
        version* {.bitsize: 3.}: uint8
        flags* {.bitsize: 5.}: uint8
        sizeOfProlog*: uint8
        countOfCodes*: uint8
        frameRegister* {.bitsize: 4.}: uint8
        frameOffset* {.bitsize: 4.}: uint8
        unwindCode*: ptr UNWIND_CODE

    #[
    typedef enum _UNWIND_OP_CODES {
    UWOP_PUSH_NONVOL = 0, /* info == register number */
    UWOP_ALLOC_LARGE,     /* no info, alloc size in next 2 slots */
    UWOP_ALLOC_SMALL,     /* info == size of allocation / 8 - 1 */
    UWOP_SET_FPREG,       /* no info, FP = RSP + UNWIND_INFO.FPRegOffset*16 */
    UWOP_SAVE_NONVOL,     /* info == register number, offset in next slot */
    UWOP_SAVE_NONVOL_FAR, /* info == register number, offset in next 2 slots */
    UWOP_SAVE_XMM128 = 8, /* info == XMM reg number, offset in next slot */
    UWOP_SAVE_XMM128_FAR, /* info == XMM reg number, offset in next 2 slots */
    UWOP_PUSH_MACHFRAME   /* info == 0: no error-code, 1: error-code */
    } UNWIND_CODE_OPS;
    ]#
    UNWIND_CODE_OPS* = enum
        UWOP_PUSH_NONVOL = 0,
        UWOP_ALLOC_LARGE,
        UWOP_ALLOC_SMALL,
        UWOP_SET_FPREG,
        UWOP_SAVE_NONVOL,
        UWOP_SAVE_NONVOL_FAR,
        UWOP_SAVE_XMM128 = 8,
        UWOP_SAVE_XMM128_FAR,
        UWOP_PUSH_MACHFRAME
