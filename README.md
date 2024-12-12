# kaleidoscope
Kaleidoscope is a library that provides fast SIMD accelerated routines for strings. 
It aims to implement some of `std/strutils`'s routines in a compatible manner, whilst being either faster than their implementation or equal in terms of performance in the worst case.
Kaleidoscope automatically detects what features your CPU has and uses the best algorithm available for it. If it cannot find one, it uses a slow*, scalar implementation.
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
- x86 CPUs with AVX2

Want to add support for another architecture? Send in a PR!

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
