import bytecode
import std/strformat

proc compile*(instructions: seq[Instruction]): string =
    let size = 30000
    var stack = newSeq[int]()
    var counter = 0
    result = &"""
section .data
    data: times {size} db 0

section .text
    global _start

_start:
    mov r8, 0
"""
    for instr in instructions:
        let (t, n) = instr.toTuple()

        case t:
        of Write:
            for i in 1..n:
                result &= "    call write_char\n"
        of Read:
            for i in 1..n:
                result &= "    call read_char\n"
        of Move:
            result &= &"""
    add r8, {n}
    cmp r8, 0
    jge .positive_{counter}
    add r8, {size}  ; Wrap negative to positive
.positive_{counter}:
    cmp r8, {size}
    jl .within_bounds_{counter}  
    sub r8, {size}  ; Wrap overflow
.within_bounds_{counter}:
"""
            counter += 1
        of Change: 
            result &= &"""
    add byte [data + r8], {n}
    and byte [data + r8], 0xFF
"""
        of LoopStart:
            result &= &"""
ls_{counter}:
    cmp byte [data + r8], 0
    jz le_{counter}
"""
            stack.add(counter)
            counter += 1
        of LoopEnd:
            assert(stack.len() > 0, "stack is empty")
            let i = stack.pop()
            result &= &"""
    jmp ls_{i}
le_{i}:
"""

    result &= """
    mov rax, 60
    mov rdi, 0
    syscall

write_char:
    mov rax, 1
    mov rdi, 1
    lea rsi, [data + r8]
    mov rdx, 1
    syscall
    ret

read_char:
    mov rax, 0
    mov rdi, 0
    lea rsi, [data + r8]
    mov rdx, 1
    syscall
    ret
"""