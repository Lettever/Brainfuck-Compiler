proc interp*(input: string) =
    var
        ip = 0
        mem: array[30000, byte]
        dp = mem.len div 2
    
    while ip < input.len:
        case input[ip]:
        of '+':
            inc mem[dp]
            inc ip
        of '-':
            dec mem[dp]
            inc ip
        of '>':
            inc dp
            inc ip
        of '<':
            dec dp
            inc ip
        of ',':
            mem[dp] = readChar(stdin).byte
            inc ip
        of '.':
            write(stdout, mem[dp].char)
            inc ip
        of '[':
            if mem[dp] == 0:
                var level = 1
                while level > 0:
                    inc ip
                    if input[ip] == '[': inc level
                    elif input[ip] == ']': dec level
            inc ip
        of ']':
            if mem[dp] != 0:
                var level = 1
                while level > 0:
                    dec ip
                    if input[ip] == ']': inc level
                    elif input[ip] == '[': dec level
            inc ip
        else: inc ip