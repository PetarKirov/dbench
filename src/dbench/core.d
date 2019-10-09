module dbench.core;

import std.algorithm : canFind;
import std.datetime : Duration;
debug import std.stdio : writefln;

struct Compiler
{
    string name;
    string path;
    string version_;

    bool isKnownCompiler() const { return isLdc || isDmdCompatible; }
    bool isLdc() const { return name == "ldc2" || name == "ldc"; }
    bool isDmdCompatible() const { return name.canFind("dmd"); }

    string versionCliFlag(string ver) const
    in (isKnownCompiler)
    {
        if (isDmdCompatible)
            return "-version=" ~ ver;
        else if (isLdc)
            return "-d-version=" ~ ver;
        else
            assert(0, "Unsupported compiler");
    }

    string semanticOnlyCliFlag() const
    in (isKnownCompiler)
    {
        return "-o-";
    }

    string compileOnlyCliFlag() const
    in (isKnownCompiler)
    {
        return "-c";
    }
}

Compiler* getCompilerInfo(string name)
{
    import std.algorithm : any;
    import std.conv : to;
    import std.file : exists;
    import std.path : asAbsolutePath, asNormalizedPath, isDirSeparator, baseName;
    import dbench.util.process : getProcessPath, parseToolVersion;

    string path;
    if (name.any!isDirSeparator && name.exists)
        path = name.asAbsolutePath.asNormalizedPath.to!string;
    else
        path = getProcessPath(name);

    if (path == null)
        return null;

    auto result = new Compiler;
    result.path = path;
    result.name = result.path.baseName;
    result.version_ = parseToolVersion(result.path);

    return result;
}

unittest
{
    // Assume that the compiler used to build this app is also
    // available when the unit tests are run.
    version (DigitalMars)
    {
        auto c = getCompilerInfo("dmd");
        assert (c.name == "dmd");
    }
    else version (LDC)
    {
        auto c = getCompilerInfo("ldc2");
        assert (c.name == "ldc2");
    }
}

struct TestSet
{
    string name;
    string dir;
    string runner;
    const(TestRun)*[] testRuns;

    const struct TestRun
    {
        string name;
        string filepath;
        TestSet* set;

        const(BenchResult*) run(
            const Compiler* compiler,
            MetricType type = MetricType.semanticTime) const
        {
            import dbench.util.process : measure;

            string[] args = [
                compiler.path,
                compiler.versionCliFlag(this.name),
                set.runner,
                this.filepath
            ];

            auto result = new BenchResult();
            result.testRun = &this;
            result.compiler = compiler;
            if (type & MetricType.semanticTime)
            {
                result.semanticTime = measure(args ~
                        compiler.semanticOnlyCliFlag);
            }
            else if (type & MetricType.compileTime)
            {
                result.compileTime = measure(args ~ compiler.compileOnlyCliFlag);
            }
            else if (type & MetricType.compileAndLinkTime)
            {
                result.compileAndLinkTime = measure(args);
            }
            else
                assert (0, "Unimplemented");

            return result;
        }
    }
}

struct BenchResult
{
    Duration semanticTime;
    Duration compileTime;
    Duration compileAndLinkTime;
    Duration runTime;
    ulong binarySize;
    const(TestSet.TestRun)* testRun;
    const(Compiler)* compiler;
}

enum MetricType
{
    none                = 0b00000,
    semanticTime        = 0b00001,
    compileTime         = 0b00010,
    compileAndLinkTime  = 0b00100,
    runTime             = 0b01000,
    objectSize          = 0b10000,
    all                 = 0b11111
}

TestSet* getTestSet(string path)
{
    import std.array : array;
    import std.algorithm : filter, map;
    import std.file : dirEntries, exists, SpanMode;
    import std.path : baseName, buildPath, stripExtension;

    auto result = new TestSet(path.baseName, path);
    result.testRuns = path
        .dirEntries("ex*.d", SpanMode.shallow)
        .filter!(de => de.isFile)
        .map!(de => new TestSet.TestRun(de.name.baseName.stripExtension, de.name, result))
        .array;

    const possibleRunnerLocation = path.buildPath("runner.d");
    if (possibleRunnerLocation.exists)
        result.runner = possibleRunnerLocation;

    return result;
}

unittest
{
    import std.algorithm : canFind, equal;
    import std.conv : to;
    import std.format : fmt = format;
    import std.file : mkdirRecurse, readText;
    import std.path : buildPath;
    import std.stdio;

    import dbench.util.push_dir : pushTmpDir;

    auto tmpDir = pushTmpDir;
    string path = "./ctfe/log_prefix";
    path.mkdirRecurse;
    foreach (i; 0 .. 4)
        "module ex%s;".fmt(i).toFile(path.buildPath("ex%s.d".fmt(i)));
    "module runner;".toFile(path.buildPath("runner.d"));

    auto testSet = path.getTestSet;
    assert(testSet.name == "log_prefix");
    assert(testSet.dir == path);
    assert(testSet.runner.readText == "module runner;");

    assert(testSet.testRuns.length == 4);
    alias pred = (a, b) => *a == *b;
    assert(testSet.testRuns.canFind!pred(
        new TestSet.TestRun("ex0", "./ctfe/log_prefix/ex0.d", testSet)));
    assert(testSet.testRuns.canFind!pred(
        new TestSet.TestRun("ex1", "./ctfe/log_prefix/ex1.d", testSet)));
    assert(testSet.testRuns.canFind!pred(
        new TestSet.TestRun("ex2", "./ctfe/log_prefix/ex2.d", testSet)));
    assert(testSet.testRuns.canFind!pred(
        new TestSet.TestRun("ex3", "./ctfe/log_prefix/ex3.d", testSet)));
}
