import nimsimd/runtimecheck

const
  noSimd* = defined(kaleidoscopeNoSimd)

let
  hasAvx2* = checkInstructionSets({ AVX2 })
  hasSse4* = checkInstructionSets({ SSE41 })
