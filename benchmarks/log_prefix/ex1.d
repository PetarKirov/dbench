module log_prefix.ex1;

template logPrefix(string domain, string file, int line)
{
    import std.path : baseName;
    enum logPrefix = mixin(`"[`, domain, `|`, file.baseName, `:`, line, `] "`);
}
