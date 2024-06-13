.686p
.xmm
.MODEL flat, stdcall
OPTION CASEMAP:NONE


.DATA
mDeg REAL8 0.0
s180 REAL8 180.0
M_PI REAL8 3.14159265358979323846
coef60 REAL8 60.0
coef100 REAL8 100.0




.CODE

OPTION LANGUAGE: SYSCALL

PUBLIC @MyProc1@0


@MyProc1@0 PROC
    mov eax, 1
    cpuid
    test edx, 04000000h
    setnz al
    movzx eax, al
    ret
@MyProc1@0 ENDP

OPTION LANGUAGE: C

PUBLIC RadToDegAsm

RadToDegAsm PROC, rad : QWORD
    sub esp, 16
    movsd xmm0, qword ptr [s180]       ; Load 180.0
    movsd xmm1, qword ptr [M_PI]       ; Load PI
    divsd xmm0, xmm1                   ; xmm0 = 180.0 / PI
    movsd xmm3, xmm0                   ; Store conversion factor
    movsd xmm0, qword ptr [rad]        ; Load input radians
    mulsd xmm0, xmm3                   ; Convert radians to degrees
    movsd xmm2, xmm0                   ; Store degrees in xmm2
    movapd xmm1, xmm0                  ; xmm1 = degrees
    cvttsd2si eax, xmm1                ; Convert degrees to integer (eax)
    cvtsi2sd xmm1, eax                 ; Convert integer degrees back to double
    subsd xmm2, xmm1                   ; Calculate fractional part
    movsd xmm3, qword ptr [coef60]     ; Load 60.0
    mulsd xmm2, xmm3                   ; Convert fractional part to minutes
    movsd xmm4, xmm1                   ; Copy integer degrees as double
    movsd xmm5, qword ptr [coef100]    ; Load 100.0
    mulsd xmm4, xmm5                   ; Multiply integer degrees by 100
    addsd xmm4, xmm2                   ; Add fractional minutes to degrees*100
    movsd qword ptr [esp+8], xmm4      ; Store result on the stack
    fld qword ptr [esp+8]              ; Load result to FPU stack
    add esp, 16                        ; Clean up stack
    ret
RadToDegAsm ENDP



END
