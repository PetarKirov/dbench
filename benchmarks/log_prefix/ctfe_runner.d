version (ex0) import log_prefix.ex0;
version (ex1) import log_prefix.ex1;
version (ex2) { import log_prefix.ex2; version = rtLine; }
version (ex3) { import log_prefix.ex3; version = rtLine; }
version (ex4) { import log_prefix.ex4; version = rtLine; }
version (ex5) import log_prefix.ex5;

static foreach (i; 0 .. 3000)
{
    version (ex5)
        pragma (msg, logPrefix!("asd", __FILE__) ~ UtoABuf!uint(i));
    else version (rtLine)
        pragma (msg, logPrefix!("asd", __FILE__)(i));
    else
        pragma (msg, logPrefix!("asd", __FILE__, i));
}
