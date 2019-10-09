version (ex0) import ex0;
version (ex1) import ex1;
version (ex2) import ex2;

static foreach (i; 0 .. 3000)
{
    version (ex2)
        pragma (msg, logPrefix!("asd", __FILE__)(i));
    else
        pragma (msg, logPrefix!("asd", __FILE__, i));
}
