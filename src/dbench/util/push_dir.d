module dbench.util.push_dir;

PushTmpDir pushTmpDir(string root = null)
{
    import std.path : buildPath;
    import std.uuid : randomUUID;
    if (root == null) root = "./build/test";
    return PushTmpDir(root.buildPath(randomUUID.toString));
}

struct PushTmpDir
{
    debug import std.stdio : writefln;
    import std.conv : to;
    import std.file : chdir, getcwd, mkdirRecurse, rmdirRecurse;
    import std.path : asNormalizedPath, asAbsolutePath;

    immutable string oldPath;
    immutable string newPath;

    this(string path)
    {
        newPath = path.asAbsolutePath.asNormalizedPath.to!string;
        debug "Creating folder '%s'".writefln(newPath);
        newPath.mkdirRecurse;
        oldPath = getcwd;
        newPath.chdir;
    }

    ~this()
    {
        debug "Removing folder '%s'".writefln(newPath);
        oldPath.chdir;
        newPath.rmdirRecurse;
    }
}
