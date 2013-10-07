#ifndef DATE_H
#define DATE_H

class Date {

 private:
  
  int day, month, year;
  
 public:

  Date(int day, int month, int year);

 bool operator==(Date date);
 
 void print();
};

#endif
