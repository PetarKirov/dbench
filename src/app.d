import std.array : array, join, replace;
import std.algorithm : map, sort;
import std.conv : to;
import std.getopt;
import std.path;
import std.range : only;
import std.stdio;

import dbench.core :
    BenchResult,
    getCompilerInfo,
    genTestSet,
    populateConfigs,
    genTestRuns,
    run;

import dbench.utils.table :
    Column,
    ColumnVisibility,
    getStructHeader,
    toCsvRow,
    Visibility;

void main(string[] args)
{
    string testDir;
    string[] compilers;
    Visibility cmdlineVisibility;

    std.getopt.arraySep = ",";
    args.getopt(
        "test-dir", &testDir,
        "compilers", &compilers,
        "cmdline-visibility", &cmdlineVisibility
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

    ColumnVisibility!Table vis;
    vis.cmdline = cmdlineVisibility;

    getStructHeader!Table(vis).writeln;
    foreach (result; results)
    {
        auto r = result;
        const setName = r.testRun.test.set.name;
        const testName = r.testRun.test.name;
        const compilerString = r.testRun.compilerConfig.compiler.name
            ~ " " ~ r.testRun.compilerConfig.compiler.version_;

        auto cmdline = (cmdlineVisibility == Visibility.full
            ? r.allFlags.replace(0, 1, only(r.allFlags[0].baseName))
            : r.testRun.compilerConfig.extraFlags
        ).join(" ");

        auto t = Table(
            setName ~ "." ~ testName,
            r.semanticTime.total!"msecs".to!string ~ "ms",
            r.compileTime.total!"msecs".to!string ~ "ms",
            r.compileAndLinkTime.total!"msecs".to!string ~ "ms",
            r.runTime.total!"msecs".to!string ~ "ms",
            r.binarySize,
            compilerString,
            cmdline
        );

        t.toCsvRow!Table(vis).writeln;
    }
}

struct Table
{
    @Column("Name")
    string name;

    @Column("Semantic")
    string semanticTime;

    @Column("Compile")
    string compileTime;

    @Column("Compile & Link")
    string compileAndLinkTime;

    @Column("Run Time")
    string runTime;

    @Column("Binary Size")
    ulong binarySize;

    @Column("Compiler")
    string compiler;

    @Column("Command Line")
    string cmdline;
}
