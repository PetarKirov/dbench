module dbg_log.ex0;

void dbgLog
    (string domain, Args...)
    (string format, Args args, string file = __FILE__, int line = __LINE__)
{
    dbgLogImpl!(domain, LogFmt.prefixAndNewLine, string, int, Args)(
        format, file, line, args);
}

enum LogFmt
{
    plain            = 0b00,
    newLine          = 0b01,
    prefix           = 0b10,
    prefixAndNewLine = 0b11
}

void dbgLogImpl
    (string domain, LogFmt logFmt, Args...)
    (string format, Args args)
{
    enum bool logDomainEnabled = ()
    {
        bool f;
        mixin("debug(", domain, ") f = true;");
        return f;
    }();

    static if (logDomainEnabled)
    {
        import std.format : fmt = format;
        import std.stdio : stdout, write;

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

        msg.write;

        static if (logFmt & LogFmt.newLine)
            '\n'.write;
        else
            stdout.flush();
    }
}
