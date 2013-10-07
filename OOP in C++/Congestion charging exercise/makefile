vehicle: date.o vehicle.o vehicleMain.o
	g++ -g -Wall date.o vehicle.o vehicleMain.o -o vehicle

date.o: date.cpp date.h
	g++ -g -Wall -c date.cpp

vehicle.o: vehicle.cpp vehicle.h
	g++ -g -Wall -c vehicle.cpp

vehicleMain.o: vehicleMain.cpp vehicle.cpp date.cpp
	g++ -g -Wall -c vehicleMain.cpp

clean:
	rm -f date.o vehicle.o vehicleMain.o vehicle
