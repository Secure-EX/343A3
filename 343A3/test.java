package jdbc;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

public class test extends JDBCSubmission {
  
  public List<Integer> yourDad() {
    JDBCSubmission jdbc = new test();
    System.out.println(jdbc.similarity("hey dude are you serious", "holy dude you are nude"));
    System.out.println("------------------------------------------------------------------------");
    ArrayList<Integer> scoreMaxList = new ArrayList<Integer>();
    Map<Integer, Double> partyScore = new Hashtable<Integer, Double>();
    // partyScore.put(4, new Double(100.0));
    partyScore.put(5, new Double(50.0));
    partyScore.put(6, new Double(80.0));
    partyScore.put(7, new Double(80.0));
    partyScore.put(8, new Double(60.0));
    partyScore.put(9, new Double(50.0));
    
    Double maxValue = Double.MIN_VALUE;
    for (Object key : partyScore.keySet()) {
      Double temp = partyScore.get(key);
      if (temp.compareTo(maxValue) > 0) {
        scoreMaxList.clear();
        scoreMaxList.add((Integer) key);
        maxValue = temp;
        System.out.println("hello?");
      } else if (temp.compareTo(maxValue) == 0) {
        scoreMaxList.add((Integer) key);
        System.out.println("bello?");
      }
    }
    
    // display value
    System.out.println("Length is: " + scoreMaxList.size());
    for (Integer temp : scoreMaxList) {
      System.out.println(temp);
    }
    return scoreMaxList;
  }

  public static void main(String[] args) {
    // TODO Auto-generated method stub
    int x = 10;
    int y = 20;
    int z = 30;
    String foo = x + "," + y + "," + z + ";";
    System.out.println(foo);
    System.out.println("------------------------------------------------------------------------");
    test t = new test();
    t.yourDad();
    Double bla = new Double(0.0);
    Double blo = new Double(5.0);
    System.out.println(bla.compareTo(blo));
    
    Float haha = new Float(3.0);
    System.out.println(blo > haha);
  }

  @Override
  public boolean connectDB(String url, String username, String password) {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public boolean disconnectDB() {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public ElectionResult presidentSequence(String countryName) {
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public List<Integer> findSimilarParties(Integer partyId, Float threshold) {
    // TODO Auto-generated method stub
    return null;
  }

}
