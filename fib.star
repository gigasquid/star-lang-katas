-- Naive fib with pattern matching 
fib(0) is 0;
fib(1) is 1;
fib(n) is fib(n-1) + fib(n-2);


main() do {
  logMsg(info, "Fib 0 is $(fib(0))");
  logMsg(info, "Fib 1 is $(fib(1))");
  logMsg(info, "Fib 2 is $(fib(2))");
  logMsg(info, "Fib 3 is $(fib(3))");
  logMsg(info, "Fib 10 is $(fib(10))");

  assert fib(0)=0;
  assert fib(1)=1;
  assert fib(3)=2;
  assert fib(10)=55;
}