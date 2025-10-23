import std/strformat

type
    InstructionType = enum
        Write,
        Read,
        Move,
        Change,
        LoopStart,
        LoopEnd
    
    Instruction = object
        `type`: InstructionType
        n: int

proc processInput(input: string): seq[Instruction] =
    result = newSeq[Instruction]()
    var
        j = 0
        stack = newSeq[int]()

    while j < input.len:
        let ch = input[j]
        var cnt = 1

        case ch:
        of '+', '-', ',', '.', '<', '>':
            inc j
            while j < input.len and input[j] == ch:
                inc j
                inc cnt

            case ch:
            of '+': result.add(Instruction(`type`: Change, n: cnt))
            of '-': result.add(Instruction(`type`: Change, n: -cnt))
            of ',': result.add(Instruction(`type`: Read, n: cnt))
            of '.': result.add(Instruction(`type`: Write, n: cnt))
            of '<': result.add(Instruction(`type`: Move, n: -cnt))
            of '>': result.add(Instruction(`type`: Move, n: cnt))
            else: discard
        
        of '[':
            let i = result.len
            result.add(Instruction(`type`: LoopStart, n: 0))
            stack.add(i)
            inc j
        
        of ']':
            assert stack.len > 0, &"No matching bracket at {j}"
            let i = stack.pop()
            result[i].n = result.len
            result.add(Instruction(`type`: LoopEnd, n: i))
            inc j
        
        else: inc j

proc run*(input: string) =
    let instructions = processInput(input)
    var
        ip = 0
        mem: array[30000, byte]
        dp = mem.len div 2

    while ip < instructions.len:
        let
            t = instructions[ip].`type`
            n = instructions[ip].n
        case t:
        of Write:
            for i in 1 .. n: write(stdout, mem[dp].char)
            inc ip
        of Read:
            for i in 1 .. n: mem[dp] = readChar(stdin).byte
            inc ip
        of Move:
            dp = (dp + n) mod mem.len
            inc ip
        of Change:
            mem[dp] += n.byte
            inc ip
        of LoopStart:
            if mem[dp] == 0: ip = n
            else: inc ip
        of LoopEnd:
            if mem[dp] != 0: ip = n
            else: inc ip