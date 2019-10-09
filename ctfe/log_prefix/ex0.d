module ex0;

template logPrefix(string domain, string file, int line)
{
    import std.format : format;
    import std.path : baseName;
    enum logPrefix = "[%s|%s:%s]".format(domain, file.baseName, line);
}
