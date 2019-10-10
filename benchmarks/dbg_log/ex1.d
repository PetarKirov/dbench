module dbg_log.ex1;

mixin template DebugLogMixin(string domain, string file = __FILE__)
{
    import dbg_log.ex1;

    void dbgLog(Args...)(string format, Args args, int line = __LINE__)
    {
        dbgLogImpl!(domain, LogFmt.prefixAndNewLine, string, int, Args)(
            format, file, line, args);
    }

    void dbgLogNoPrefix(Args...)(string format, Args args)
    {
        dbgLogImpl!(domain, LogFmt.newLine, Args)(format, args);
    }

    void dbgLogNoNewLine(Args...)(string format, Args args, int line = __LINE__)
    {
        dbgLogImpl!(domain, LogFmt.prefix, string, int, Args)(
            format, file, line, args);
    }
}

enum LogFmt
{
    plain            = 0b00,
    newLine          = 0b01,
    prefix           = 0b10,
    prefixAndNewLine = 0b11
}

enum isDebugVersionOn(string name) = ()
{
    mixin("debug(", name, ") return true; else return false;");
}();

void dbgLogImpl
    (string domain, LogFmt logFmt, Args...)
    (string format, Args args)
{
    static if (isDebugVersionOn!domain)
    {
        import std.format : fmt = format;
        version (none) import core.stdc.stdio : fflush, fwrite, puts, stdout;
        else import std.stdio : stdout, write;

        static if (logFmt & LogFmt.prefix)
        {
            import std.path : baseName;
            const file = args[0].baseName;
            alias line = args[1];
            alias rest = args[2..$];
            string msg = fmt("[%s|%s:%s] " ~ format, domain, file, line, rest);
        }
        else
            string msg = fmt(format, args);

        version (none)
        {
            fwrite(msg.ptr, 1, msg.length, stdout);

            static if (logFmt & LogFmt.newLine)
                puts("");
            else
                fflush(stdout);
        }
        else
        {
            msg.write;

            static if (logFmt & LogFmt.newLine)
                '\n'.write;
            else
                stdout.flush();
        }
    }
}
