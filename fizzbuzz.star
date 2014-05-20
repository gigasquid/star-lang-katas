fzbz(X) is case X in {
  Y where Y%5=0 and Y%3=0 is "fizzbuzz";
  Y where Y%3=0 is "fizz";
  Y where Y%5=0 is "buzz";
  _ default is "$X";
};

fizzbuzz has type (integer) => string;
fizzbuzz(N) where N%3=0 and N%5=0 is "fizzbuzz";
fizzbuzz(N) where N%3=0 is "fizz";
fizzbuzz(N) where N%5=0 is "buzz";
fizzbuzz(N) default is "$N";

main() do {
  logMsg(info, "fzbz(3) is $(fzbz(3))");
  logMsg(info, "fzbz(5) is $(fzbz(5))");
  logMsg(info, "fzbz(15) is $(fzbz(15))");
  logMsg(info, "fzbz(2) is $(fzbz(2))");
  logMsg(info, "Fizzbuzz(3) is $(fizzbuzz(3))");
  logMsg(info, "Fizzbuzz(5) is $(fizzbuzz(5))");
  logMsg(info, "Fizzbuzz(15) is $(fizzbuzz(15))");
  logMsg(info, "Fizzbuzz(2) is $(fizzbuzz(2))");

};