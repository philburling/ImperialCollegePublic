

/**
 * Complete the implementation of this class in line with the FSP model
 */

public class PlatformAccess {

  /* declarations required */
  private boolean occupied = false;

  public synchronized void arrive() throws InterruptedException {
    // complete implementation
	  while(occupied) wait();
	  occupied = true;
	  notifyAll();
	  return;
  }

  public synchronized void depart() {
    // complete implementation
	  if (!occupied) {System.out.println("ERROR -Tried to depart when unoccupied");}
	  occupied = false;
	  notifyAll();
	  return;
  }

}