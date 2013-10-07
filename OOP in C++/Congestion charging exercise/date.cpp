#include <iostream>
#include <iomanip>
#include "date.h"

using namespace std;

Date::Date(int init_day, int init_month, int init_year) {

  day = init_day;
  month = init_month;
  year = init_year;
}

bool Date::operator==(Date date) {

  if ((day == date.day) && (month == date.month) && (year == date.year)) {
    return true;
  } else {
    return false;
  }
}

void Date::print() {
  cout << setw(2) << setfill('0') << day << "/" << setw(2) << setfill('0') << month << "/" << year;
}
