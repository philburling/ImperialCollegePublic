#include <iostream>
#include "date.h"
#include "vehicle.h"

using namespace std;

int main () {

  cout << "====================================" << endl;
  cout << "Vehicle charging system operational!" << endl;
  cout << "====================================" << endl;

  Lorry lorry ( "L10RRY", 12 );
  Bus tessa ( "T3SSA" );

  tessa.board ( 10 );

  lorry.enter ( Date(2,10,2011), 10 );

  Vehicle::set_rate ( 2.00 );
  DieselCar::set_limit ( 10 );

  tessa.enter ( Date(2,10,2011), 11 );
  tessa.leave ( 5 );
  tessa.enter ( Date(2,10,2011), 13 );

  PetrolCar milly ( "M1LLY" );
  DieselCar vanilli ( "V4NLI", 15 );

  milly.enter ( Date(2,10,2011), 16 );
  vanilli.enter ( Date(2,10,2011), 17 );

  Vehicle::set_rate ( 2.50 );

  vanilli.enter ( Date(3,10,2011), 2 );

  tessa.board ( 20 );
  tessa.enter ( Date(3,10,2011), 14 );

  DieselCar::set_limit ( 20 );
  vanilli.enter ( Date(01,01,2012), 10 );
  lorry.enter ( Date(01,01,2012), 11 );

  cout << "=====================================" << endl;
  cout << "Vehicle charging system powered down!" << endl;
  cout << "=====================================" << endl;

  return 0;
}
