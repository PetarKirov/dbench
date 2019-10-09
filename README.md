# DBench

A workbench for benchmarking compile-time, run-time and binary size of D
programs.

Example:
```
$ dub run -q -- --test-dir=./ctfe/log_prefix/ --compilers=ldc2
Name,Compiler,Time
log_prefix.ex0,ldc2 1.16.0,1512ms
log_prefix.ex1,ldc2 1.16.0,837ms
log_prefix.ex2,ldc2 1.16.0,761ms
```

To make the CSV output a bit more readable one can use a separate tool like
this:
```
$ dub run -q -- --test-dir=./ctfe/log_prefix/ --compilers=ldc2 | tablize
+----------------+-------------+--------+
| Name           | Compiler    | Time   |
+----------------+-------------+--------+
| log_prefix.ex0 | ldc2 1.16.0 | 1512ms |
| log_prefix.ex1 | ldc2 1.16.0 | 837ms  |
| log_prefix.ex2 | ldc2 1.16.0 | 761ms  |
+----------------+-------------+--------+
```
