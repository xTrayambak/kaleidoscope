# found this whilst fuzzing
import pkg/kaleidoscope/search

let data = readFile("tests/b002.txt")
echo data.repr
data.find("big chungus").echo

echo data.repr
