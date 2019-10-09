import std.array : array;
import std.algorithm : map, sort;
import std.conv : to;
import std.getopt;
import std.path;
import std.stdio;

import dbench.core : getTestSet, getCompilerInfo, BenchResult;

void main(string[] args)
{
    string testDir;
    string[] compilers;

    std.getopt.arraySep = ",";
    args.getopt(
        "test-dir", &testDir,
        "compilers", &compilers
    );

    auto testSet = getTestSet(testDir);
    debug (Main) "Running %s tests in benchmark '%s'..."
        .writefln(testSet.testRuns.length, testSet.name);

    testSet.testRuns.sort!((a, b) => a.name < b.name);

    auto compilerInfos = compilers.map!(c => c.getCompilerInfo).array;

    const(BenchResult)*[] results;

    foreach (compiler; compilerInfos)
    {
        debug (Main) writeln(*compiler);

        foreach (testRun; testSet.testRuns)
        {
            results ~= testRun.run(compiler);
        }
    }

    "Name,Compiler,Time".writeln;
    foreach (result; results)
    {
        import std.typecons : t = tuple;
        auto r = result;
        "%(%s%|,%)".writefln(t(
            r.testRun.set.name ~ "." ~ r.testRun.name,
            r.compiler.name ~ " " ~ r.compiler.version_,
            r.semanticTime.total!"msecs".to!string ~ "ms"
            )
        );
    }
}

