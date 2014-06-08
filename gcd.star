import worksheet

worksheet{

/**
 Euclid's Algorithim
 http://en.wikipedia.org/wiki/Greatest_common_divisor
**/

  gcd has type (integer, integer) => integer
  gcd(a,0) is a
  gcd(0,b) is b
  gcd(a,b) where a = b is a
  gcd(a,b) where a > b is gcd(a-b,b)
  gcd(a,b) where b > a is gcd(a,b-a)

  assert gcd(3,0) = 3
  assert gcd(0,3) = 3
  assert gcd(48,180) = 12
  assert gcd(9,28) = 1

  }