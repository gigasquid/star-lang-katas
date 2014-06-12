bookflight is package{

  main() do {
/**
  Create an actor that you can book and cancel flights with speech acts

    F is flight("flight123", 5)
    notify F with book("Carin") on Tx
    notify F with book("Bob") on Tx
    notify F with book("Alice") on Tx
    notify F with book("Tom") on Tx
    notify F with book("Ted") on Tx
    notify F with book("Bruce") on Tx
    x is query F's getPassengerList with getPassengerList()
    logMsg(info, "pList is $x")
    assert x = list of {"Carin"; "Bob"; "Alice"; "Tom"; "Ted"}

    notify F with cancel("Tom") on Tx
    y is query F's getPassengerList with getPassengerList()
    assert y = list of {"Carin"; "Bob"; "Alice"; "Ted"}
    logMsg(info, "pList is $y")

    request F's setFlightStatus to setFlightStatus("closed")
    notify F with book("Nancy") on Tx
    assert y = list of {"Carin"; "Bob"; "Alice"; "Ted"}
**/
  }

}