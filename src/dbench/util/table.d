module dbench.utils.table;

// Column UDA
struct Column { string name; }

enum Visibility
{
    none,
    lite,
    full
}

alias ColumnVisibility(Table) =
    FieldMetaData!(Table, Visibility, Visibility.full);

string getStructHeader(T)(
    ColumnVisibility!T visibility = ColumnVisibility!T.init)
{
    import std.traits : hasUDA, getUDAs;
    string header;
    uint idx;
    static foreach (field; T.tupleof)
        static if (hasUDA!(field, Column))
        {
            if (visibility.opDispatch!(field.stringof))
            {
                if (idx++ > 0)
                    header ~= mixin(`",`, getUDAs!(field, Column)[0].name, `"`);
                else
                    header ~= getUDAs!(field, Column)[0].name;
            }
        }
    return header;
}

///
unittest
{
    static struct Table
    {
        @Column("Age")
        int age;

        @Column("Name")
        string name;

        @Column("Email")
        string email;

        // Unlabeled
        double otherField;
    }

    ColumnVisibility!Table vis;
    assert (getStructHeader!Table(vis) == "Age,Name,Email");

    vis.age = Visibility.none;
    assert (getStructHeader!Table(vis) == "Name,Email");

    vis.age = Visibility.full;
    vis.email = Visibility.none;
    assert (getStructHeader!Table(vis) == "Age,Name");
}

string toCsvRow(T)(in ref T obj,
    ColumnVisibility!T visibility = ColumnVisibility!T.init)
{
    import std.conv : text;
    import std.traits : hasUDA, getUDAs;
    string row;
    uint i;
    static foreach (idx, field; T.tupleof)
        static if (hasUDA!(field, Column))
        {
            if (visibility.opDispatch!(field.stringof))
            {
                if (i++ > 0)
                    row ~= text(',', obj.tupleof[idx]);
                else
                    row ~= text(obj.tupleof[idx]);
            }
        }
    return row;
}

///
unittest
{
    static struct Table
    {
        @Column("Age")
        int age;

        @Column("Name")
        string name;

        @Column("Email")
        string email;

        // Unlabeled
        double otherField;
    }

    auto t = Table(23, "John", "john@doe.com", 3.25);

    ColumnVisibility!Table vis;
    assert (toCsvRow!Table(t, vis) == "23,John,john@doe.com");

    vis.age = Visibility.none;
    assert (toCsvRow!Table(t, vis) == "John,john@doe.com");

    vis.age = Visibility.full;
    vis.email = Visibility.none;
    assert (toCsvRow!Table(t, vis) == "23,John");
}

struct FieldMetaData(Obj, Data, Data init = Data.init)
{
    Data[Obj.tupleof.length] memberIndexedData = init;

    ref inout(Data) opIndex(string memberName) inout
    {
        import std.traits : hasUDA, getUDAs;
        final switch (memberName)
        {
            static foreach (idx, field; Obj.tupleof)
                static if (hasUDA!(field, Column))
                    case getUDAs!(field, Column)[0].name:
                        return memberIndexedData[idx];
        }
    }

    ref inout(Data) opDispatch(string memberName)() inout
    {
        import std.meta : staticIndexOf;
        import std.traits : FieldNameTuple;
        enum idx = staticIndexOf!(memberName, FieldNameTuple!Obj);
        static assert (idx != size_t.max,
            "Member `" ~ memberName ~ "` not found.");
        return memberIndexedData[idx];
    }
}



