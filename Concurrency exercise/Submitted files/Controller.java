

/**
 * Complete the implementation of this class in line with the FSP model
 */

import display.*;

public class Controller {

  public static int Max = 9;
  protected NumberCanvas passengers;

  // declarations required
  private int count;
  private int waitingCarSize;
  private boolean buttonPressed;

  public Controller(NumberCanvas nc) {
    passengers = nc;
    count = 0;
    waitingCarSize = 0;
    buttonPressed = false;
  }

  public synchronized void newPassenger() throws InterruptedException {
     // complete implementation
     while (!(count < Max)) wait();
     count++;
	 // use "passengers.setValue(integer value)" to update display
     passengers.setValue(count);
     notifyAll();
     return;
  }

  public synchronized int getPassengers(int mcar) throws InterruptedException {
     // complete implementation for part I

	  while ((!((mcar > 0) && (count >= mcar))) && (!((mcar > 0) && (count > 0) && (count < mcar) && (buttonPressed == true)))) {
		  waitingCarSize = mcar; //So that the goNow button only registers when under the right conditions.
		  wait();
	  }
	  if ((count < mcar) && (buttonPressed == true)) {
		  mcar = count;
	  }
	 count = count - mcar;
     waitingCarSize = 0;
	 buttonPressed = false; //So that the press is not remembered between cars
     // use "passengers.setValue(integer value)" to update display
     passengers.setValue(count);
     notifyAll();
     return mcar;
  }

  public synchronized void goNow() {
    // complete implementation for part II
	  if ((waitingCarSize > 0) && (count > 0) && (count < waitingCarSize) && (buttonPressed == false)){
	  buttonPressed = true;
	  }
	  notifyAll();
	  return;
  }

}