[Package]
name          = "brainfuck"
version       = "1.0"
author        = "Dennis Felsing"
description   = "A brainfuck interpreter and compiler"
license       = "MIT"

srcDir        = "src"
bin           = "brainfuck"

[Deps]
Requires: "nim >= 0.10.0, docopt >= 0.1.0"
