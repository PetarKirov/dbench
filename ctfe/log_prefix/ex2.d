module ex2;

string logPrefix(string domain, string file)(int line)
{
    import std.conv : to;
    import std.path : baseName;
    return
        mixin(`"[`, domain, `|`, file.baseName, `:"`) ~ line.to!string ~ "] ";
}
