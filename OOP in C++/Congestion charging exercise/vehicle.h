using namespace std;

#ifndef VEHICLE_H
#define VEHICLE_H
#include <string>

class Vehicle {

 private:
  //Could include a 'bool has_exemption_rule' attribute
  double money_owed;
  const string number_plate;
  static double unit_cost;
  Date date_last_charged;

  const virtual void vehicle_type_message() = 0;
  void display_entry_message(Date date, int hour);
  void determine_and_apply_charge(Date date, int hour);
  const virtual int units_to_charge(int hour) = 0;

 protected:

  Vehicle(string number_plate);
  const string get_number_plate();

 public:

  void enter(Date date, int hour);
  static void set_rate(double new_rate);

};

class Bus : public Vehicle {
  
 private:
  
  int passenger_count;

  const void vehicle_type_message(); //virtual
  const int units_to_charge(int hour); //virtual
 
 protected:
  const int get_passenger_count();

 public:
                                 
  Bus(string number_plate);  
  void board(int passengers);  
  void leave(int passengers);

};


class Lorry : public Vehicle {
  
 private:
  
  const int axles;

  const void vehicle_type_message(); //virtual
  const int units_to_charge(int hour); //virtual
  
 public:
  
  Lorry(string number_plate, int axles);

};


class Car : public Vehicle {

 protected:

  Car(string number_plate);
  const int units_to_charge(int hour); //virtual
  const virtual int car_type_units_to_charge() = 0; //pure virtual
};


class DieselCar : public Car {
  
 private:
  
  const int emissions_rating;
  static int qualifying_threshold;
  const void vehicle_type_message(); //virtual
  const int car_type_units_to_charge(); //virtual
  
 public:
  
  DieselCar(string number_plate, int emissions_rating);
  static void set_limit (int new_threshold);
  
};


class PetrolCar : public Car {
  
 private:

  const void vehicle_type_message(); //virtual
  const int car_type_units_to_charge(); //virtual
  
 public:
  
  PetrolCar(string number_plate);

};

#endif
