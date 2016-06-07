# Package

version       = "1.0"
author        = "Dennis Felsing"
description   = "A brainfuck interpreter and compiler"
license       = "MIT"

srcDir        = "src"
bin           = @["brainfuck"]

# Dependencies

requires "nim >= 0.10.0"
requires "docopt >= 0.1.0"

task tests, "Run the Brainfuck tester":
  exec "nim c -r tests/all"
