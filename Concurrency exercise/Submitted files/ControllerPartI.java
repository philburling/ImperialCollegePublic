

/**
 * Complete the implementation of this class in line with the FSP model
 */

import display.*;

public class Controller {

  public static int Max = 9;
  protected NumberCanvas passengers;

  // declarations required
  private int count;

  public Controller(NumberCanvas nc) {
    passengers = nc;
    count = 0;
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

	  while (!((mcar > 0) && (count >= mcar))) wait();
	  /*N.B. I don't think I need this check for >0. All it does is ensures that cars that can carry no passengers have to wait forever and consequently
	  block the platform. Personally I'd remove it, but I've left it in to show that I've thought about this.*/
	  count = count - mcar;

     // update for part II
     // use "passengers.setValue(integer value)" to update display
     passengers.setValue(count);
     notifyAll();
     return mcar;
  }

  public synchronized void goNow() {
    // complete implementation for part II
  }

}