| n start elapsed a b tmp |

"Benchmark 1: tight integer loop — tests bytecode dispatch"
n := 0.
start := Time millisecondClockValue.
1 to: 20000000 do: [:i | n := n + 1].
elapsed := Time millisecondClockValue - start.
Transcript show: 'loop_20M_ms=' , elapsed printString; nl.

"Benchmark 2: integer arithmetic — tests SmallInt unboxing"
n := 0.
start := Time millisecondClockValue.
1 to: 10000000 do: [:i | n := n + i].
elapsed := Time millisecondClockValue - start.
Transcript show: 'arith_10M_ms=' , elapsed printString; nl.

"Benchmark 3: iterative fibonacci x100k — tests JIT inlining"
start := Time millisecondClockValue.
1 to: 100000 do: [:iter |
    a := 0. b := 1.
    1 to: 40 do: [:i | tmp := b. b := a + b. a := tmp]].
elapsed := Time millisecondClockValue - start.
Transcript show: 'fib40_100k_ms=' , elapsed printString; nl.

"Benchmark 4: block closure allocation — tests GC pressure"
start := Time millisecondClockValue.
n := 0.
1 to: 1000000 do: [:i | n := [:x | x * x] value: i].
elapsed := Time millisecondClockValue - start.
Transcript show: 'closure_alloc_1M_ms=' , elapsed printString; nl.

Smalltalk quitPrimitive: 0.
