-- Naive fib with pattern matching
import worksheet

worksheet{
  fib(0) is 0
  fib(1) is 1
  fib(n) is fib(n-1) + fib(n-2)

  show "Fib 0 is $(fib(0))"
  show "Fib 1 is $(fib(1))"
  show "Fib 2 is $(fib(2))"
  show "Fib 3 is $(fib(3))"
  show "Fib 10 is $(fib(10))"

  assert fib(0)=0;
  assert fib(1)=1;
  assert fib(3)=2;
  assert fib(10)=55;
}