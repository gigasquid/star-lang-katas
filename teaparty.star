import worksheet

/**
"Welcome should return the greeting with the proper title
depending on whether it is a man, woman, or knight.
A woman is addressed as Ms.
A man is addressed as Mr.
A knight is addressed as Sir.
The return string should be Welcome (the title) (last name)"
**/

worksheet{

  welcome has type (string, boolean, boolean) => string
  welcome(s,true,_) is "Welcome Ms. " ++ s
  welcome(s,false,false) is "Welcome Mr. " ++ s
  welcome(s,false,true) is "Welcome Sir " ++ s

  assert welcome("Austen", true, false) = "Welcome Ms. Austen"
  assert welcome("Orwell", false, false) = "Welcome Mr. Orwell"
  assert welcome("Newton", false, true) = "Welcome Sir Newton"

}

