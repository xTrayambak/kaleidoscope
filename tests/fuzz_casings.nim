import pkg/drchaos
import pkg/kaleidoscope/casings

proc fuzzTarget(data: string) =
  echo toLowerAscii(data)

defaultMutator(fuzzTarget)
