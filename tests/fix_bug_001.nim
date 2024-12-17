# found this whilst fuzzing
import pkg/kaleidoscope/casings

let data = readFile("tests/b001.txt")
toLowerAscii(data).echo()
