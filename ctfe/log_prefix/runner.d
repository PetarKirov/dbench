version (ex0) import ex0;
version (ex1) import ex1;
version (ex2) { import ex2; version = rtLine; }
version (ex3) { import ex3; version = rtLine; }
version (ex4) { import ex4; version = rtLine; }

static foreach (i; 0 .. 3000)
{
    version (rtLine)
        pragma (msg, logPrefix!("asd", __FILE__)(i));
    else
        pragma (msg, logPrefix!("asd", __FILE__, i));
}
