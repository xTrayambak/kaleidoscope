import pkg/kaleidoscope/common

when not noSimd:
  import pkg/nimsimd/[popcnt, avx2]

  when defined(amd64):
    func countAvx2(str: string, sub: char): uint64 =
      ## AVX2 implementation of the counting function.
      let length = uint64(str.len)
      var
        target = mm256_set1_epi8(cast[uint8](sub))
        cnt, i: uint64

      while i + 31 < length:
        let
          chunk = mm256_loadu_si256(cast[ptr M256](str[i].addr))
          cmp = mm256_cmpeq_epi8(chunk, target)
          mask = mm256_movemask_epi8(cmp)

        cnt += uint64(popcnt32(mask))

        i += 32

      while i < length:
        if str[i] == sub:
          inc cnt

        inc i

      cnt

    func countSse(str: string, sub: char): uint64 =
      ## SSE implementation of the counting function.
      let length = uint64(str.len)
      var
        target = mm_set1_epi8(cast[uint8](sub))
        cnt, i: uint64

      while i + 16 < length:
        let
          chunk = mm_loadu_si128(cast[ptr M128](str[i].addr))
          cmp = mm_cmpeq_epi8(chunk, target)
          mask = mm_movemask_epi8(cmp)

        cnt += uint64(popcnt32(mask))

        i += 16

      while i < length:
        if str[i] == sub:
          inc cnt

        inc i

      cnt

func countScalar(str: string, sub: char): uint64 =
  ## Scalar/fallback implementation of the counting function.
  ##
  ## This is pretty much the same thing as what `std/strutils` does.
  var cnt: uint64

  for c in str:
    if c == sub:
      inc cnt

  cnt

proc count*(str: string, sub: char): uint64 {.inline.} =
  ## This function counts the number of times `sub` occurs in `str`.
  ##
  ## This function uses SIMD acceleration whenever possible.
  when not noSimd:
    if hasAvx2:
      return countAvx2(str, sub)
    elif hasSse4:
      return countSse(str, sub)

  return countScalar(str, sub)
