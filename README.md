# kaleidoscope
Kaleidoscope is a library that provides fast SIMD accelerated routines for strings.

It aims to implement some of `std/strutils`'s routines in a compatible manner, whilst being either faster than their implementation or equal in terms of performance in the worst case. \
Kaleidoscope automatically detects what features your CPU has and uses the best algorithm available for it. If it cannot find one, it uses a scalar implementation. \
In order to always force the scalar implementation to be used, compile your program with `--define:kaleidoscopeNoSimd`.

This library is written in pure Nim.

# Performance
You can run `tests/test1.nim` on your system to find out. On my laptop, with a Ryzen 5 5500H, this is the result:
```
$ nim c -d:release -r tests/test1.nim
   min time    avg time  std dv   runs name
   0.006 ms    0.006 ms  ±0.000  x1000 find needle in haystack (std/strutils)
   0.000 ms    0.000 ms  ±0.000  x1000 find needle in haystack (kaleidoscope)
```

Although, keep in mind that whilst Kaleidoscope outperforms the standard library in release mode, it does not in debug builds with array-checks switched on as it bottlenecks the SIMD operations by a considerable margin.
```
$ nim c -r tests/test1.nim
   min time    avg time  std dv   runs name
   0.006 ms    0.006 ms  ±0.000  x1000 find needle in haystack (std/strutils)
   0.032 ms    0.033 ms  ±0.002  x1000 find needle in haystack (kaleidoscope)
```

# Supported CPUs
- x86 CPUs with AVX2 or SSE4.1

Want to add support for another architecture? Send in a PR!

# Credits
This project would have not been possible without the following articles and/or gists.
- [easyaspi314's SSE4.1-based case-conversion code](https://gist.github.com/easyaspi314/9d31e5c0f9cead66aba2ede248b74d64)
- [Wojciech Muła's article "SIMD-friendly algorithms for substring searching"](http://0x80.pl/articles/simd-strfind.html)

# Security
This project can be fuzzed via LLVM's fuzzing infrastructure alongside AddressSanitizer. That's already helped me in squashing a few bugs here. \
There's still some issues left, and as such, I would not recommend you to use this library in production as of right now.

# Real World Usage
This project has been used in the [Bali JavaScript engine](https://github.com/ferus-web/bali) for implementing the following methods:
- `String.prototype.indexOf` (string-find)
- `String.prototype.toLowerCase` (case-conversion)
- `String.prototype.toUpperCase` (case-conversion)

It blows other JavaScript engines like SpiderMonkey and Boa's implementations out of the water in [this benchmark](https://github.com/ferus-web/bali/blob/master/benchmarks/string-find.sh), but does get outperformed by QuickJS (although that's probably due to other engine details, not Kaleidoscope itself)

# Installation
```command
$ nimble add https://github.com/xTrayambak/kaleidoscope
```

# Usage
Kaleidoscope works on both the C and C++ backends.

```nim
import pkg/kaleidoscope

let haystack = "Hello world!"
let needle = "world"

let pos = haystack.find(needle)
```

# Roadmap
- Add ARM support (I do not own an ARM CPU apart from my phone, if any of you do, please try to add it)
- Add RISC-V support (same as above, I do not own a RISC-V machine)
