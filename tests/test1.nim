import std/[strutils]
import kaleidoscope/search
import pkg/benchy

let haystack = readFile("tests/data/julius-caesar.txt") # shakespeare's a real homie for this one
let needle = "rent the envious Casca"

timeIt "find needle in haystack (std/strutils)":
  let pos {.used.} = strutils.find(haystack, needle)

timeIt "find needle in haystack (kaleidoscope)":
  let pos {.used.} = search.find(haystack, needle)
