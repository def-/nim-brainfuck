import unittest, brainfuck

suite "brainfuck interpreter":
  test "interpret helloworld":
    let helloworld = readFile("examples/helloworld.b")
    check interpret(helloworld, "") == "Hello World!\n"

  test "interpret rot13":
    let rot13 = readFile("examples/rot13.b")
    let conv = interpret(rot13, "How I Start\n")
    check conv == "Ubj V Fgneg\n"
    check interpret(rot13, conv) == "How I Start\n"
