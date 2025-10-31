import std/[
    os,
    strformat,
    re
]
import src/[
    interpreter,
    bytecode,
    transpiler,
    compiler,
]

proc printHelp() =
    echo "Usage: ./bfc [bcit] <file>"
    echo "  b - bytecode"
    echo "  c - compile to assembly"
    echo "  i - interpret"
    echo "  t - transpile to C"

proc isValidOption(option: string): bool = option.match(re"^[bcit]$")

proc main() =
    let count = paramCount()
    if count != 2:
        printHelp()
        quit(1)

    let option = paramStr(1)
    if not isValidOption(option):
        echo &"Error: '{option}' is not a valid option"
        printHelp()
        quit(1)
    
    let filePath = paramStr(2)
    if not fileExists(filePath):
        echo &"Error: Could not access '{filePath}'"
        return
    let text = readFile(filePath)

    case option:
    of "b":
        let code = processInput(text)
        bytecode(code)
    of "c":
        let code = processInput(text)
        writeFile("out.asm", compile(code))
        let cmdResult = execShellCmd("nasm -f elf64 out.asm -o out.o && ld out.o -o out && rm out.o")
        if cmdResult == 0:
            echo "Created ./out file"
        else:
            echo "Error: Build failed"
            quit(1)
    of "i":
        interp(text)
    of "t":
        let code = processInput(text)
        writeFile("out.c", transpile(code))
        let cmdResult = execShellCmd("gcc out.c -o out && rm out.c")
        if cmdResult == 0:
            echo "Success: Created ./out executable"
        else:
            echo "Error: Compilation failed"
            quit(1)
    else: assert(false, &"Unreachable with option '{option}'")
    
when isMainModule:
    main()