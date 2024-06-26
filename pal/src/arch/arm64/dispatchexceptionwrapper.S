//-------------------------------------------------------------------------------------------------------
// ChakraCore/Pal
// Contains portions (c) copyright Microsoft, portions copyright (c) the .NET Foundation and Contributors
// and edits (c) copyright the ChakraCore Contributors.
// See THIRD-PARTY-NOTICES.txt in the project root for .NET Foundation license
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//-------------------------------------------------------------------------------------------------------

//
// Implementation of the PAL_DispatchExceptionWrapper that is
// interposed between a function that caused a hardware fault
// and PAL_DispatchException that throws an SEH exception for
// the fault, to make the stack unwindable.
//

#include "unixasmmacros.inc"

// Offset of the return address from the PAL_DispatchException in the PAL_DispatchExceptionWrapper
.globl C_FUNC(PAL_DispatchExceptionReturnOffset)
C_FUNC(PAL_DispatchExceptionReturnOffset):
    .int LOCAL_LABEL(PAL_DispatchExceptionReturn) - C_FUNC(PAL_DispatchExceptionWrapper)

//
// PAL_DispatchExceptionWrapper will never be called; it only serves
// to be referenced from a stack frame on the faulting thread.  Its
// unwinding behavior is equivalent to any standard function.
// It is analogous to the following source file.
//
// extern "C" void PAL_DispatchException(CONTEXT *pContext, EXCEPTION_RECORD *pExceptionRecord, MachExceptionInfo *pMachExceptionInfo);
//
// extern "C" void PAL_DispatchExceptionWrapper()
// {
//     CONTEXT Context;
//     EXCEPTION_RECORD ExceptionRecord;
//     MachExceptionInfo MachExceptionInfo;
//     PAL_DispatchException(&Context, &ExceptionRecord, &MachExceptionInfo);
// }
//

NESTED_ENTRY PAL_DispatchExceptionWrapper, _TEXT, NoHandler
    PROLOG_SAVE_REG_PAIR_INDEXED fp, lr, -16
    // Should never actually run
    EMIT_BREAKPOINT
    bl      EXTERNAL_C_FUNC(PAL_DispatchException)
LOCAL_LABEL(PAL_DispatchExceptionReturn):
    // Should never return
    EMIT_BREAKPOINT
    EPILOG_RESTORE_REG_PAIR_INDEXED fp, lr, 16
    ret
NESTED_END PAL_DispatchExceptionWrapper, _TEXT
