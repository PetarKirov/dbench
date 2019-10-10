module dbg_log.ex2;

mixin template DebugLogMixin2(string domain, string file = __FILE__)
{
    import log_prefix.ex1 : logPrefix;
    import dbg_log.ex2 : dbgLogImpl2, isDebugVersionOn;
    pragma (inline, true):

    void dbgLog(int line = __LINE__, Args...)(string format, auto ref Args args)
    {
        static if (isDebugVersionOn!(domain))
        {
            enum prefix = logPrefix!(domain, file, line);
            dbgLogImpl2!true(prefix ~ format, args);
        }
    }
}

enum isDebugVersionOn(string name) = ()
{
    mixin("debug(", name, ") return true; else return false;");
}();

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
