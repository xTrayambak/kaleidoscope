import pkg/drchaos
import pkg/kaleidoscope/search

proc fuzzTarget(data: (string, string)) =
  echo data[0].find(data[1])

defaultMutator(fuzzTarget)
