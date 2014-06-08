import worksheet

worksheet{

  countdown has type (integer) => cons of integer
  countdown(0) is cons of {0}
  countdown(n) is cons(n, countdown(n-1))

  show countdown(5)
  assert countdown(5) = cons of {5;4;3;2;1;0}

  show countdown(0)
  assert countdown(0) = cons of {0}
}