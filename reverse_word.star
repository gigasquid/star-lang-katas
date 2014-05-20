-- Reverse a given input of a word

reverseWord (word) is reverse(word);

main() do {
  result is reverseWord("cat");
  assert result="tac"
  logMsg(info, "reverse of cat is $result");
}