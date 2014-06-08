-- Reverse a given input of a word

-- easy way out with build in string function
reverseWordEasy(word) is reverse(word);

-- a little more difficult
reverseSeq has type (cons of char) => cons of char;
reverseSeq(S) is let{
  rev(_empty(),R) is R;
  rev(_pair(H,T),R) is rev(T, cons(H,R));
} in rev(S,_nil());

reverseWord has type (string) => cons of char;
reverseWord(s) is reverseSeq(explode(s)) ;



main() do {
  result is reverseWordEasy("cat");
  assert result="tac"
  logMsg(info, "reverseWordEasy(cat) is $result");

  w is reverseWord("dog");

  logMsg(info, "Reverse is $w ");

}