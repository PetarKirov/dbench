module ex3;

string logPrefix(string domain, string file)(int line)
{
    import std.conv : text;
    import std.path : baseName;
    return
        mixin(`"[`, domain, `|`, file.baseName, `:"`) ~ text(line) ~ "] ";
}
