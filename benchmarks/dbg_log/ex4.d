module dbg_log.ex4;

mixin template DebugLogMixin4(string domain, string file = __FILE__)
{
    import dbg_log.ex4 : dbgLogImpl2, isDebugVersionOn;
    pragma (inline, true):

    void dbgLog(Args...)(string format, auto ref Args args, uint line = __LINE__)
    {
        static if (isDebugVersionOn!(domain))
        {
            import log_prefix.ex5 : logPrefix, UtoABuf;
            const prefix = logPrefix!(domain, file) ~ UtoABuf!uint(line);
            dbgLogImpl2!true(prefix ~ format, args);
        }
    }
}

pragma (inline, false)
void dbgLogImpl2(bool newLine, Args...)(const(char)[] format, Args args)
{
    import std.stdio : writef, writefln, stdout;

    static if (newLine)
        writefln(format, args);
    else
    {
        writef(format, args);
        stdout.flush();
    }
}

enum isDebugVersionOn(string name) = ()
{
    mixin("debug(", name, ") return true; else return false;");
}();

