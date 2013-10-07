/* This file contains all the member functions methods for the Vehicle class and its subclasses */

#include <iostream>
#include <iomanip>
#include <string>
#include "date.h"
#include "vehicle.h"

using namespace std;

double Vehicle::unit_cost = 1.00; //Initializing a static member

int DieselCar::qualifying_threshold = 5; //Initializing a static member



/* Constructor functions */

Vehicle::Vehicle(string n_plate) : number_plate(n_plate), date_last_charged(01,01,1970) { //abstract class
  money_owed = 0;
  cout.setf(ios::fixed);
  cout.precision(2);
  /*N.B. those floating point display modifications are specifically here to ensure that no Vehicle class or subclass functions are called before these have been set. This also allows the settings for all functions to be changed in one place.*/
}  
Bus::Bus(string number_plate) : Vehicle(number_plate) {
  passenger_count = 0;
  cout << "***   A bus (" << number_plate << ") has been registered" << endl << endl;
}
Lorry::Lorry(string number_plate, int init_axles) : Vehicle(number_plate), axles(init_axles) {
  cout << "***   A " << axles << "-axle lorry (" << number_plate << ") has been registered" << endl << endl;
}
Car::Car(string number_plate) : Vehicle(number_plate) {} /*abstract class*/

DieselCar::DieselCar(string number_plate, int init_emissions_rating) : Car(number_plate), emissions_rating(init_emissions_rating) {
  cout << "***   A " << emissions_rating << "-ppcm diesel car (" << number_plate << ") has been registered" << endl << endl;
}
PetrolCar::PetrolCar(string number_plate) : Car(number_plate) {
  cout << "***   A petrol car (" << number_plate << ") has been registered" << endl << endl;
}


/* Accessor functions */

const string Vehicle::get_number_plate() {
  return number_plate;
}


/* Mutator functions */

//Alter the cost of a single unit charged for all vehicles
void Vehicle::set_rate(double new_rate) {
  cout << "***   The council sets the basic unit charge to #" << new_rate << endl << endl;
  unit_cost = new_rate;
}

void Vehicle::determine_and_apply_charge(Date date, int hour) {
  double charge = static_cast<double>(units_to_charge(hour))*unit_cost;
    if (charge > 0) {
      money_owed += charge;
      date_last_charged = date;
      cout << "      The vehicle is charged #" << charge;
    } else {
      cout << "      The vehicle goes free";
    }
    cout << " (now owes #"<< money_owed << ")" << endl << endl; 
}

void Bus::board(int passengers) {
  passenger_count += passengers;
  cout << "***   " << passengers << " passengers board the bus (" << get_number_plate() << "), so " << passenger_count <<" passengers are on board" << endl << endl;
}

void Bus::leave(int passengers) {
  passenger_count -= passengers;  
  cout << "***   " << passengers << " passengers leave the bus (" << get_number_plate() << "), leaving " << passenger_count <<" passengers on board" << endl << endl;
}

void DieselCar::set_limit (int new_threshold){
  qualifying_threshold = new_threshold;
  cout << "***   The council says diesel cars with emissions less than " << qualifying_threshold << ".00 ppcm\n      should pay a reduced rate" << endl << endl;

}


/* Member functions to cater for the variation in the vehicle entry message */

void Vehicle::display_entry_message(Date date, int hours) {
  cout << "***   The ";
  vehicle_type_message();
  cout << " (" << number_plate << ")";
  cout << " enters on ";
  date.print();
  cout << " at " << setw(2) << setfill('0') << hours << "h00 hours" << endl;
}

const void Bus::vehicle_type_message() {
  cout << "bus";
}
const void Lorry::vehicle_type_message() {
  cout << axles << "-axle lorry";
}
const void DieselCar::vehicle_type_message() {
  cout << emissions_rating << "-ppcm diesel car";
}
const void PetrolCar::vehicle_type_message() {
  cout << "petrol car";
}


//Decide on entry whether a vehicle should be charged or not and then charge it accordingly
void Vehicle::enter(Date date, int hour) {
  display_entry_message(date,hour);
  if (date == date_last_charged) { //Note this test assumes that the function will not be called for dates before the last date that vehicle was charged. 
    cout << "      The vehicle has already been charged today ; no action is taken" << endl << endl;    
  } else {
    determine_and_apply_charge(date,hour);
  }
}


/* Member functions to calculate how many units should be charged for a specific vehicle depending on its type and attributes */
const int Bus::units_to_charge(int hours) { //virtual 
  if (passenger_count >= 20 ) {
    return 0;
  } else {
    return 5;
  }
}

const int Lorry::units_to_charge(int hours) { //virtual
  return axles;
}

const int Car::units_to_charge(int hours) { //virtual
  if ((hours <=9) || (hours >=18)) {
    return 0;
  } else {
    return car_type_units_to_charge();
  }
}

const int DieselCar::car_type_units_to_charge() { //virtual
  if (emissions_rating > qualifying_threshold) {    
    return 3;
  } else {
    return 1;
  }
}

const int PetrolCar::car_type_units_to_charge() { //virtual
  return 2;
}
