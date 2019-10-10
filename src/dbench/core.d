module dbench.core;

import std.array : array, join, split;
import std.algorithm : any, canFind, cartesianProduct, filter, map, sort;
import std.conv : to;
import std.datetime : Duration;
import std.range : chain;
import std.string : strip;
debug import std.stdio : writefln;

enum MetricType
{
    none           = 0b00000,
    semanticTime   = 0b00001,
    compileTime    = 0b00010,
    linkTime       = 0b00100,
    wholeBuildTime = 0b00111,
    runTime        = 0b01000,
    binarySize     = 0b10000,
    all            = 0b11111
}

struct Metric(T, MetricType type)
{
    T value;
    alias value this;
    string cliArgs;
}

alias SemanticTime = Metric!(Duration, MetricType.semanticTime);
alias CompileTime = Metric!(Duration, MetricType.compileTime);
alias WholeBuildTime = Metric!(Duration, MetricType.wholeBuildTime);
alias RunTime = Metric!(Duration, MetricType.runTime);
alias BinarySize = Metric!(ulong, MetricType.binarySize);

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

    string outputPathCliFlag(string path) const
    in (isKnownCompiler)
    {
        return "-of" ~ path;
    }
}

Compiler* getCompilerInfo(string name)
{
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

const struct CompilerConfig
{
    Compiler* compiler;
    string[] extraFlags;
}

struct TestSet
{
    string name;
    string dir;
    string ctfeOnlyRunner;
    string runner;
    const(Test*)[] tests;

    const struct Test
    {
        string name;
        string filepath;
        TestSet* set;
    }
}

const struct TestRun
{
    TestSet.Test* test;
    CompilerConfig* compilerConfig;
}

struct BenchResult
{
    SemanticTime semanticTime;
    CompileTime compileTime;
    WholeBuildTime compileAndLinkTime;
    RunTime runTime;
    BinarySize binarySize;
    TestRun* testRun;
    string[] allFlags;
}

const(BenchResult*) run(
    TestRun* testRun,
    MetricType type = MetricType.all)
{
    import std.file : mkdirRecurse;
    import std.path : buildPath;
    import dbench.util.process : measure;

    const compiler = testRun.compilerConfig.compiler;
    const extraFlags = testRun.compilerConfig.extraFlags;
    const test = testRun.test;
    const set = testRun.test.set;

    const buildDir = ".".buildPath("build", set.name);
    buildDir.mkdirRecurse;
    const binaryPath = buildDir.buildPath("runner");

    string[] args = [
        compiler.path,
        test.filepath,
        null,
        compiler.versionCliFlag(test.name),
        compiler.outputPathCliFlag(binaryPath)
    ] ~ extraFlags;

    auto pRunner = &args[2];

    auto result = new BenchResult();
    result.testRun = testRun;
    result.allFlags = args;
    if (type & MetricType.semanticTime)
    {
        *pRunner = set.ctfeOnlyRunner;
        result.semanticTime = measure(args ~
                compiler.semanticOnlyCliFlag);
    }
    if (set.runner == null) return result;
    *pRunner = set.runner;
    if (type & MetricType.compileTime)
    {
        result.compileTime = measure(args ~ compiler.compileOnlyCliFlag);
    }
    if (type & MetricType.wholeBuildTime)
    {
        result.compileAndLinkTime = measure(args);
    }
    if (type & MetricType.binarySize)
    {
        import std.file : getSize;
        result.binarySize = binaryPath.getSize;
    }
    if (type & MetricType.runTime)
    {
        result.runTime = measure([binaryPath]);
    }

    //if (type >= MetricType.runTime)
    //    assert (0, "Unimplemented");

    return result;
}

TestRun*[] genTestRuns(
    const TestSet* testSet,
    const CompilerConfig*[] compilerConfigs)
{
    import std.typecons : reverse;
    return compilerConfigs
        .cartesianProduct(testSet.tests)
        .map!(tup => new TestRun(tup.reverse.expand))
        .array;
}


const(CompilerConfig*[]) populateConfigs(
    const Compiler*[] compilers, string path)
{
    import std.file : dirEntries, readText, SpanMode;
    string[][] extraDFlagsVariations = path
        .dirEntries("extra_dmd_flags*.txt", SpanMode.shallow)
        .filter!(de => de.isFile)
        .map!(de => de.name.readText.strip.split(" "))
        .array;

    if (!extraDFlagsVariations.length) extraDFlagsVariations = [[]];

    auto dmdCompilerRuns = compilers
       .filter!(c => c.isDmdCompatible)
       .cartesianProduct(extraDFlagsVariations)
       .map!(tup => new CompilerConfig(tup.expand));

    string[][] extraLdcFlagsVaraitions = path
        .dirEntries("extra_ldc_flags*.txt", SpanMode.shallow)
        .filter!(de => de.isFile)
        .map!(de => de.name.readText.strip.split(" "))
        .array;

    if (!extraLdcFlagsVaraitions.length) extraLdcFlagsVaraitions = [[]];

    auto ldcCompilerRuns = compilers
       .filter!(c => c.isLdc)
       .cartesianProduct(extraLdcFlagsVaraitions)
       .map!(tup => new CompilerConfig(tup.expand));

    return dmdCompilerRuns.chain(ldcCompilerRuns).array;
}

const(TestSet*) genTestSet(string path)
{
    import std.file : dirEntries, exists, readText, SpanMode;
    import std.path : baseName, buildPath, stripExtension;
    import std.string : strip;

    auto result = new TestSet(path.baseName, path);

    result.tests = path
        .dirEntries("ex*.d", SpanMode.shallow)
        .filter!(de => de.isFile)
        .map!(de => new TestSet.Test(
            de.name.baseName.stripExtension, de.name, result))
        .array
        .sort!((a, b) => a.name < b.name).release;

    const runner = path.buildPath("runner.d");
    result.runner = runner.exists? runner : null;

    const ctfeRunner = path.buildPath("ctfe_runner.d");
    result.ctfeOnlyRunner = ctfeRunner.exists? ctfeRunner : runner;

    return result;
}

unittest
{
    import std.algorithm : canFind, equal;
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

    auto testSet = path.genTestSet;
    assert(testSet.name == "log_prefix");
    assert(testSet.dir == path);
    assert(testSet.runner.readText == "module runner;");

    assert(testSet.tests.length == 4);
    alias pred = (a, b) => *a == *b;
    assert(testSet.tests.canFind!pred(
        new TestSet.Test("ex0", "./ctfe/log_prefix/ex0.d", testSet)));
    assert(testSet.tests.canFind!pred(
        new TestSet.Test("ex1", "./ctfe/log_prefix/ex1.d", testSet)));
    assert(testSet.tests.canFind!pred(
        new TestSet.Test("ex2", "./ctfe/log_prefix/ex2.d", testSet)));
    assert(testSet.tests.canFind!pred(
        new TestSet.Test("ex3", "./ctfe/log_prefix/ex3.d", testSet)));
}
