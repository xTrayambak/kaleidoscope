import std/strutils
import pkg/kaleidoscope/counting, pkg/benchy

let x = readFile("tests/data/julius-caesar.txt")

timeIt "std/strutils":
  let cnt {.used.} = strutils.count(x, 'l')

timeIt "kaleidoscope":
  let cnt {.used.} = counting.count(x, 'l')
