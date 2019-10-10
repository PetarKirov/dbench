module log_prefix.ex5;

template logPrefix(string domain, string file)
{
    import std.path : baseName;
    enum logPrefix = mixin(`"[`, domain, `|`, file.baseName, `:"`);
}

struct UtoABuf(T)
if (__traits(isUnsigned, T))
{
    private char[bufSize!T] buf = void;
    private ubyte start;
    auto get() const { return buf[start .. $]; }
    alias get this;

    this(T value)
    {
        ubyte i = buf.length - 1;
        while (value >= 10)
        {
            buf[i--] = cast(char)('0' + value % 10);
            value /= 10;
        }
        buf[i] = cast(char)('0' + value);
        start = i;
    }
}

template bufSize(T)
if (__traits(isUnsigned, T))
{
    import core.internal.string : numDigits;
    enum bufSize = T.max.numDigits;
}
