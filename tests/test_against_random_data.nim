## Test kaleidoscope's search module against arbitrary data
import std/[random, strutils, unittest]
import kaleidoscope/search

var buffs = newSeq[string](1000)
var needles = newSeq[string](1000)
var curr = 0

for i in 0 ..< 1000:
  buffs[curr] &= cast[char](rand(0 .. 255))

  if rand(0 .. 1) == 1:
    needles[curr] &= cast[char](rand(0 .. 255))

  if rand(0 .. 10) in [4, 8, 10]:
    inc curr

suite "kaleidoscope/search against arbitrary data":
  test "find()":
    for i, val in buffs:
      let x {.used.} = search.find(val, needles[i])
