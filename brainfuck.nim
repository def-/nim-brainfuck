proc interpret*(code: string) =
  ## Interprets the brainfuck `code` string, reading from stdin and writing to
  ## stdout.
  var
    tape = newSeq[char]()
    codePos = 0
    tapePos = 0

  proc run(skip = false): bool =
    while tapePos >= 0 and codePos < code.len:
      if tapePos >= tape.len:
        tape.add '\0'

      if code[codePos] == '[':
        inc codePos
        let oldPos = codePos
        while run(tape[tapePos] == '\0'):
          codePos = oldPos
      elif code[codePos] == ']':
        return tape[tapePos] != '\0'
      elif not skip:
        case code[codePos]
        of '+': inc tape[tapePos]
        of '-': dec tape[tapePos]
        of '>': inc tapePos
        of '<': dec tapePos
        of '.': stdout.write tape[tapePos]
        of ',': tape[tapePos] = stdin.readChar
        else: discard

      inc codePos

  discard run()

import macros

proc compile(code: string): PNimrodNode {.compiletime.} =
  var stmts = @[newStmtList()]

  template addStmt(text): stmt =
    stmts[stmts.high].add parseStmt(text)

  addStmt "var tape: array[1_000_000, char]"
  addStmt "var codePos = 0"
  addStmt "var tapePos = 0"

  for c in code:
    case c
    of '+': addStmt "inc tape[tapePos]"
    of '-': addStmt "dec tape[tapePos]"
    of '>': addStmt "inc tapePos"
    of '<': addStmt "dec tapePos"
    of '.': addStmt "stdout.write tape[tapePos]"
    of ',': addStmt "tape[tapePos] = stdin.readChar"
    of '[': stmts.add newStmtList()
    of ']':
      var loop = newNimNode(nnkWhileStmt)
      loop.add parseExpr("tape[tapePos] != '\\0'")
      loop.add stmts.pop
      stmts[stmts.high].add loop
    else: discard

  result = stmts[0]
  #echo result.repr

macro compileString*(code: string): stmt =
  ## Compiles the brainfuck `code` string into Nim code that reads from stdin
  ## and writes to stdout.
  compile code.strval

macro compileFile*(filename: string): stmt =
  ## Compiles the brainfuck code read from `filename` at compile time into Nim
  ## code that reads from stdin and writes to stdout.
  compile staticRead(filename.strval)

when isMainModule:
  import docopt, tables, strutils

  proc mandelbrot = compileFile("examples/mandelbrot.b")

  let doc = """
brainfuck

Usage:
  brainfuck mandelbrot
  brainfuck interpret [<file.b>]
  brainfuck (-h | --help)
  brainfuck (-v | --version)

Options:
  -h --help     Show this screen.
  -v --version  Show version.
"""

  let args = docopt(doc, version = "brainfuck 1.0")

  if args["mandelbrot"]:
    mandelbrot()

  elif args["interpret"]:
    let code = if args["<file.b>"]: readFile($args["<file.b>"])
               else: readAll stdin

    interpret(code)
