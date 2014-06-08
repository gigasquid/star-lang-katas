-- Reverse a given input of a word

-- easy way out with build in string function
reverseWordEasy(word) is reverse(word)

-- a little more difficult
reverseSeq has type (cons of char) => string
reverseSeq(S) is let{
  rev(_empty(),R) is R
  rev(_pair(H,T),R) is rev(T, H as string ++ R)
} in rev(S, "")

reverseWord has type (string) => string
reverseWord(s) is reverseSeq(explode(s))

main() do {
  result is reverseWordEasy("cat")
  assert result="tac"
  logMsg(info, "reverseWordEasy(cat) is $result")

  w is reverseWord("bird")
  assert w="drib"
  logMsg(info, "ReverseWord is $w ")
}