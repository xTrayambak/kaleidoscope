import std/strutils
import pkg/kaleidoscope/common

const
  a = cast[uint8]('a')
  A = cast[uint8]('A')
  z = cast[uint8]('z')
  Z = cast[uint8]('Z')

when not noSimd:
  import pkg/nimsimd/sse41

  {.push checks: off.}
  func toLowerAsciiSse4*(str: string): string {.inline.} =
    ## SSE4.1 implementation of `toLowerAscii`
    ## The remaining characters are fed to the standard library's implementation, since
    ## the number of characters at that point is lower than 16 and probably won't take
    ## much time to process anyways.
    ## https://gist.github.com/easyaspi314/9d31e5c0f9cead66aba2ede248b74d64
    var
      len = str.len
      pos = 0
      buffer = newStringOfCap(str.len - 1)

    let
      asciiA = mm_set1_epi8(A)
      asciiZ = mm_set1_epi8(Z + 1'u8)
      diff = mm_set1_epi8(a - A)

    while len >= 16:
      let
        inp = mm_loadu_si128(cast[ptr M128i](str[pos].addr))
        greaterThanA = mm_cmpgt_epi8(inp, asciiA)
        lessEqualZ = mm_cmplt_epi8(inp, asciiZ)
        mask = mm_and_si128(greaterThanA, lessEqualZ)
        toAdd = mm_and_si128(mask, diff)
        added = mm_add_epi8(inp, toAdd)

      mm_storeu_si128(cast[ptr M128i](buffer[pos].addr), added)
      len -= 16
      pos += 16

    while len > 0:
      if buffer.len - 1 < pos:
        buffer.setLen(pos + 1)

      buffer[pos] = toLowerAscii(str[pos])
      inc pos
      dec len

  func toUpperAsciiSse4*(str: string): string {.inline.} =
    ## SSE4.1 implementation of `toUpperAscii`
    ## The remaining characters are fed to the standard library's implementation, since
    ## the number of characters at that point is lower than 16 and probably won't take
    ## much time to process anyways.
    ## https://gist.github.com/easyaspi314/9d31e5c0f9cead66aba2ede248b74d64
    var
      len = str.len
      pos = 0
      buffer = newStringOfCap(str.len - 1)

    let
      asciiA = mm_set1_epi8(a)
      asciiZ = mm_set1_epi8(z)
      diff = mm_set1_epi8(a - A)

    while len >= 16:
      let
        inp = mm_loadu_si128(cast[ptr M128i](str[pos].addr))
        greaterThanA = mm_cmpgt_epi8(inp, asciiA)
        lessEqualZ = mm_cmplt_epi8(inp, asciiZ)
        mask = mm_and_si128(greaterThanA, lessEqualZ)
        toSub = mm_and_si128(mask, diff)
        subbed = mm_sub_epi8(inp, toSub)

      mm_storeu_si128(cast[ptr M128I](buffer[pos].addr), subbed)
      len -= 16
      pos += 16

    while len > 0:
      buffer[pos] = toLowerAscii(str[pos])
      inc pos
      dec len

  {.pop.}

proc toLowerAscii*(str: string): string {.inline.} =
  ## Convert `str` to lowercase ASCII.
  ##
  ## This function uses SIMD acceleration whenever possible.
  when noSimd:
    return strutils.toLowerAscii(str)
  else:
    if hasSse4:
      return toLowerAsciiSse4(str)
    else:
      return strutils.toLowerAscii(str)

proc toUpperAscii*(str: string): string {.inline.} =
  ## Convert `str` to uppercase ASCII.
  ##
  ## This function uses SIMD acceleration whenever possible.
  when noSimd:
    return strutils.toUpperAscii(str)
  else:
    if hasSse4:
      return toUpperAsciiSse4(str)
    else:
      return strutils.toUpperAscii(str)
