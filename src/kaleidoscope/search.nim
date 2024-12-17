import std/bitops
import kaleidoscope/common

when not noSimd:
  import pkg/nimsimd/[avx2, sse41]

func mm_mpsadbw_epu8_correct*(a, b: M128i, imm8: int32 | uint32): M128i {.importc: "_mm_mpsadbw_epu8", header: "smmintrin.h".}

func findScalar(haystack, needle: string): int {.inline.} =
  ## Scalar implementation of a very naive string search algorithm
  ## Source: i made it up
  for i, h in haystack:
    if h == needle[0]:
      var flag = true
      if i + needle.len - 1 > haystack.len - 1:
        continue

      for n in 1 ..< needle.len:
        if haystack[i + n] != needle[n]:
          flag = false
          break

      if flag:
        return i

proc builtin_ctz(x: cuint): cint {.importc: "__builtin_ctz", cdecl.}

when not noSimd:
  template clearLeftmostSet[T](value: T): T =
    if value == 0:
      T(0)
    else:
      T(value and value - 1)
  
  {.push checks: off.}
  func findAvx2(haystack, needle: string): int {.inline.} =
    ## AVX2 implementation of string-find
    ## Source: http://0x80.pl/articles/simd-strfind.html
    debugecho "hlen: " & $haystack.len
    debugecho "nlen: " & $needle.len
    let
      first = mm256_set1_epi8(cast[uint8](needle[0]))
      last = mm256_set1_epi8(cast[uint8](needle[needle.len - 1]))
  
    var i: int
    while i < haystack.len:
      if i + needle.len - 1 > haystack.len: break
      let
        blockFirst = mm256_loadu_si256(cast[ptr M256i](haystack[i].addr))
        blockLast = mm256_loadu_si256(cast[ptr M256i](haystack[i + needle.len - 1].addr))

        eqFirst = mm256_cmpeq_epi8(first, blockFirst)
        eqLast = mm256_cmpeq_epi8(last, blockLast)
      
      var mask: uint32 = cast[uint32](mm256_movemask_epi8(mm256_and_si256(eqFirst, eqLast)))

      while mask != 0:
        let bitpos = firstSetBit(mask) - 1

        if cmpMem(haystack[i + bitpos + 1].addr, needle[1].addr, needle.len - 2) == 0:
          return i + bitpos
      
        mask = mask.clearLeftmostSet()
      
      i += 32
  
    -1

  func findSse4(haystack, needle: string): int {.inline.} =
    let
      prefix = mm_loadu_si128(cast[ptr M128i](needle[0].addr))
      zeros = mm_setzero_si128()

    var i: int
    while i < needle.len - 1:
      let
        data = mm_loadu_si128(cast[ptr M128i](haystack[i].addr))
        res = mm_mpsadbw_epu8_correct(data, prefix, 0)
        cmp = mm_cmpeq_epi16(res, zeros)

      var mask = mm_movemask_epi8(cmp) and 0x5555

      while mask != 0:
        let bitpos = int(builtin_ctz(mask.cuint).int / 2)

        if cmpMem(haystack[i + bitpos + 4].addr, needle[4].addr, needle.len - 4) == 0:
          return i + bitpos

        mask = clearLeftmostSet(mask)

      i += 8

    -1
  {.pop.}

proc find*(haystack, needle: string): int {.inline.} =
  if needle.len > haystack.len:
    return 0

  if needle.len == 1 and haystack.len == 1:
    return (
      if needle[0] == haystack[0]:
        1
      else:
        -1
    )

  case needle.len
  of 0: return 0
  else:
    when noSimd:
      return findScalar(haystack, needle)
    else:
      if hasAvx2:
        return findAvx2(haystack, needle)
      elif hasSse4:
        return findSse4(haystack, needle)
      else:
        return findScalar(haystack, needle)

proc contains*(haystack, needle: string): bool {.inline.} =
  haystack.find(needle) != -1
