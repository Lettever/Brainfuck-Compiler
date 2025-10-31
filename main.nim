import std/[os, times, strformat]
import src/[
    interpreter as interp,
    bytecode as byco,
    #transpiler,
    #compiler
]

proc main() =
    let count = paramCount()
    if count == 0:
        echo "Usage ./bfc <file>"
        return
    let filePath = paramStr(1)
    if not fileExists(filePath):
        echo "Could not access: ", filePath
        return

    let code = readFile(filePath)
    var start = getTime()
    interp.run(code)
    var duration = getTime() - start
    echo &"naive {filePath}: Execution time: {duration.inMicroseconds} microseconds ({duration.inNanoseconds} ns)"
    start = getTime()
    byco.run(code)
    duration = getTime() - start
    echo &"optmized {filePath}: Execution time: {duration.inMicroseconds} microseconds ({duration.inNanoseconds} ns)"
    echo ""

when isMainModule:
    main()