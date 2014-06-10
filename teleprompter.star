import worksheet

/**
"Given an input text string and a list of slang words
and their translations, return a string cleansed of the slang words,
by replacing them with their translations."
**/


worksheet{

  type dictEntry is dictEntry{
    slang has type string
    cleaned has type string
  }

  hizzleEntry is dictEntry { slang="hizzle"; cleaned="house" }
  brainspinEntry is dictEntry { slang="brainspin"; cleaned="insomnia" }
  dict is cons of { hizzleEntry; brainspinEntry}


  replaceString has type (string,string,string) => string
  replaceString(s,slang,cleaned) where findstring(s,slang,0) = -1 is s
  replaceString(s,slang,cleaned) where findstring(s,slang,0) > -1 is let{
    foundIndex is findstring(s,slang,0)
    toIndex is foundIndex + size(slang)
    newstring is foundIndex > -1 ? _splice(s, foundIndex, toIndex , cleaned) | s
  } in replaceString(newstring,slang,cleaned)

  cleanString has type (string, cons of dictEntry) => string
  cleanString(s,nil) is s
  cleanString(s,_pair(h,r)) is cleanString( replaceString(s, h.slang, h.cleaned) ,r )


  teleprompt(s) is cleanString(s,dict)

  assert teleprompt("In the hizzle") = "In the house"
  assert teleprompt("In the hizzle, hizzle") = "In the house, house"
  assert teleprompt("In the hizzle, suffering from brainspin") = "In the house, suffering from insomnia"
}