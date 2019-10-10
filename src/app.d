import std.array : array, join;
import std.algorithm : map, sort;
import std.conv : to;
import std.getopt;
import std.path;
import std.stdio;

import dbench.core :
    BenchResult,
    getCompilerInfo,
    genTestSet,
    populateConfigs,
    genTestRuns,
    run;

void main(string[] args)
{
    string testDir;
    string[] compilers;

    std.getopt.arraySep = ",";
    args.getopt(
        "test-dir", &testDir,
        "compilers", &compilers
    );

    const compilerInfos = compilers.map!(c => c.getCompilerInfo).array;
    const compilerConfigs = compilerInfos.populateConfigs(testDir);
    const testSet = genTestSet(testDir);
    const testRuns = genTestRuns(testSet, compilerConfigs);

    const(BenchResult)*[] results;

    foreach (testRun; testRuns)
    {
        results ~= testRun.run();
    }

    "Name,Semantic,Compile,Compile & Link,Run Time,Size,Compiler,Flags"
        .writeln;
    foreach (result; results)
    {
        import std.typecons : t = tuple;
        auto r = result;
        const setName = r.testRun.test.set.name;
        const testName = r.testRun.test.name;
        const compilerString = r.testRun.compilerConfig.compiler.name
            ~ " " ~ r.testRun.compilerConfig.compiler.version_;
        "%(%s%|,%)".writefln(t(
            setName ~ "." ~ testName,
            r.semanticTime.total!"msecs".to!string ~ "ms",
            r.compileTime.total!"msecs".to!string ~ "ms",
            r.compileAndLinkTime.total!"msecs".to!string ~ "ms",
            r.runTime.total!"msecs".to!string ~ "ms",
            r.binarySize,
            compilerString,
            r.testRun.compilerConfig.flags.join(" "),
            )
        );
    }
}

