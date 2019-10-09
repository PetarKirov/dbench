module dbench.util.process;

import core.time : Duration;
import std.stdio : File;

@property File devNull()
{
    version (Posix)
        enum devNull = "/dev/null";
    else version (Windows)
        enum devNull = "nul";
    static File res;
    if (!res.isOpen) res = File(devNull, "w");
    return res;
}

/++
Gets the path to a command by running it and then using OS APIs to query
information about the running process.
Supports:
* Windows
* Linux
+/
string getProcessPath(string cmd)
{
    import std.exception : assumeUnique;
    import std.process : spawnProcess;
    import std.stdio : File;

    auto nullFile = devNull;
    auto pid = spawnProcess(cmd, nullFile, nullFile, nullFile);
    enum bufSize = 1024;
    auto buf = new char[](bufSize);
    uint bytesWritten = bufSize;

    version (Windows)
    {
        import std.windows.syserror : wenforce;
        QueryFullProcessImageNameA(pid.osHandle, 0, buf.ptr, &bytesWritten).wenforce("fail");
        return buf.ptr[0 .. bytesWritten].assumeUnique;
    }
    else version (linux)
    {
        import core.sys.posix.unistd : readlink;
        import std.algorithm : canFind;
        import std.array : split;
        import std.exception : errnoEnforce;
        import std.file : readText;
        import std.format : fmt = format;

        auto cmdline = "/proc/%s/cmdline".fmt(pid.osHandle)
            .readText.split('\0');

        if (cmdline[0].canFind("bash"))
            return cmdline[2]; // bash -[c|e] path-to-compiler-shebang-script
        else
            return cmdline[0];
    }
    else
        static assert(0, "Unsupported platform");
}

private version (Windows)
{
    import core.sys.windows.windows : BOOL, HANDLE, DWORD, LPSTR, PDWORD;
    // _WIN32_WINNT >= 0x0600
    extern (Windows) BOOL QueryFullProcessImageNameA(
        HANDLE hProcess,
        DWORD  dwFlags,
        LPSTR lpExeName,
        PDWORD lpdwSize
    );
}

string parseToolVersion(string path)
{
    import std.exception : enforce;
    import std.process : execute;
    import std.regex : matchFirst, regex;
    import std.traits : ReturnType;

    string[] versionFlags = ["--version", "-version", "-v"];

    ReturnType!execute res;
    string ver;
    foreach (flag; versionFlags)
    {
        res = execute([path, flag]);
        if (res.status != 0) continue;

        auto match = res.output
            .matchFirst(regex(`(\d+\.)(\d+\.)(\d+)([.\-\+~\w]+)?`));

        if (!match.empty) // success
        {
            ver = match.hit;
            break;
        }
    }
    (res.status == 0)
        .enforce("Couldn't obtain version infromation about `" ~ path ~ "`. " ~
            "Error message:\n^^^^^^^^^^^^^\n" ~ res.output ~ "vvvvvvvvvvvvv");

    (ver != null)
        .enforce("Couldn't obtain version infromation about `" ~ path ~ "`. ");

    return ver;
}

Duration measure(string[] cmdline)
{
    import core.time : MonoTime;
    import std.conv : to;
    import std.format : fmt = format;
    import std.exception : enforce;
    import std.process : pipeProcess, Redirect, wait;
    debug (MeasureProcess) import std.stdio : writef, writefln;
    auto nullFile = devNull;
    const start = MonoTime.currTime;
    debug (MeasureProcess) "Process: `%-(%s %)`".writef(cmdline);
    auto pipes = pipeProcess(
        cmdline,
        Redirect.stderrToStdout | Redirect.stdout
    );
    int res = pipes.pid.wait();
    string output;
    foreach (line; pipes.stdout.byLine)
    {
        output ~= line;
        output ~= '\n';
    }

    enforce(res == 0,
        "Command `%-(%s %)` failed with code %s. Output:\n%s"
            .fmt(cmdline, res, output)
    );
    const duration = MonoTime.currTime - start;
    debug (MeasureProcess)
    {
        auto ms = duration.total!"msecs";
        " -> rc=%s time=%sms".writefln(res, ms);
    }
    return duration;
}
