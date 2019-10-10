module dbg_log.ex3;

mixin template DebugLogMixin3(string domain, string file = __FILE__)
{
    import log_prefix.ex4 : logPrefix;
    import dbg_log.ex3 : dbgLogImpl2, isDebugVersionOn;
    pragma (inline, true):

    void dbgLog(Args...)(string format, auto ref Args args, int line = __LINE__)
    {
        static if (isDebugVersionOn!(domain))
        {
            const prefix = logPrefix!(domain, file)(line);
            dbgLogImpl2!true(prefix ~ format, args);
        }
    }
}

pragma (inline, false)
void dbgLogImpl2(bool newLine, Args...)(string format, Args args)
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

