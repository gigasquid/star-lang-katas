bookflight is package{
  type tx is book(string) or cancel(string);

  flight((FlightName has type string), (MaxPeople has type integer)) is actor{
    var plist := list {};
    var flightStatus := "open";

    setFlightStatus(s) do { flightStatus := s };

    on book(pname) on Tx do
        logMsg(info,"booking $pname on #FlightName's flight: max #MaxPeople current $(size(plist))");
    on book(pname) on Tx where size(plist) < MaxPeople do
      extend plist with pname;
    on book(pname) on Tx where size(plist) >= MaxPeople do
      logMsg(info, "sorry .. the flight is full");
    on book(pname) on Tx where flightStatus != "open" do
      logMsg(info, "sorry .. the flight is no longer open");

    on cancel(pname) on Tx do
      delete (X where X = pname) in plist;

    getPassengerList has type () => list of string;
    getPassengerList() is plist;
    }


  main() do {
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
  }

}