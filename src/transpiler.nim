import instruction
import std/strformat

proc transpile*(instructions: seq[Instruction]): string =
    result = """
    #include <stdio.h>
    int main() {
        unsigned char mem[30000] = { 0 };
        int dp = 15000;
    """

    for instr in instructions:
        let t = instr.`type`
        let n = instr.n
        case t:
        of Change: result &= &"mem[dp] += {n};\n"
        of Move: result &= &"dp += {n};\n if (dp < 0) dp += 30000;\n dp %= 30000;\n"
        of Write:
            for i in 1..n:
                result &= "putchar(mem[dp]);\n"
        of Read:
            for i in 1..n:
                result &= "mem[dp] = getchar();\n"
        of LoopStart:
            result &= "while (mem[dp]) {\n"
        of LoopEnd:
            result &= "}\n"
    result &= "return 0;\n}"

let
    path = "./examples/hello.bf"
    code = processInput(readFile(path))

writeFile("out.c", transpile(code))