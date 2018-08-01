import java.sql.*;
import java.util.List;
import java.util.ArrayList;

public class Assignment3 extends JDBCSubmission {

  // TEST BLOCK START <-------------------------------------------------------------------

  // // JDBC driver name and database URL
  // // static final String JDBC_DRIVER = "org.postgresql.Driver";
  // static final String url = "jdbc:postgresql://localhost:5432/csc343h-xieruiyu";
  //
  // // Database credentials
  // static final String username = "xieruiyu";
  // static final String password = "mcnxshwdd";
  //
  // // Country name
  // static final String countryName = "Germany";
  //
  // // Similar party id
  // static final Integer partyID = 305;
  // static final Float threshold = (float) 0.25;

  // TEST BLOCK END <-------------------------------------------------------------------
  
  public Assignment3() throws ClassNotFoundException {
    // Register JDBC driver
    try {
      Class.forName("org.postgresql.Driver");
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
      System.out.println("Couldn't find Driver");
    }
  }

  @Override
  /**
   * Connect database
   * 
   * @param url: url of the server
   * @param username: name of the user
   * @param password: password of the user return boolean
   */
  public boolean connectDB(String url, String username, String password) {
    // write your code here.
    try {
      // Open a connection
      System.out.println("Connecting to database");
      connection = DriverManager.getConnection(url, username, password);
      System.out.println("Connection Success");
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("Connection fail");
    } catch (Exception ex) {
      ex.printStackTrace();
      System.out.println("Connection fail");
    }
    return true;
  }

  @Override
  /**
   * Disconnect database
   * 
   * return boolean
   */
  public boolean disconnectDB() {
    // write your code here.
    try {
      // Close a connection
      System.out.println("Disconnecting from database");
      if (connection != null) {
        connection.close();
      }
      System.out.println("Disconnection Success");
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("Disconnection fail");
    } catch (Exception ex) {
      ex.printStackTrace();
      System.out.println("Disconnection fail");
    }
    return true;
  }
  
  @Override
  /**
   * Given a country, returns the list of Presidents in that country, in descending order of date
   * of occupying the office, and the name of the party to which the president belonged.
   * 
   * @param countryName: name of the country
   * @return null
   */
  public ElectionResult presidentSequence(String countryName) {
    // Two list of presidentSequence
    List<Integer> presidentsList = new ArrayList<Integer>();
    List<String> partyNamesList = new ArrayList<String>();
    ElectionResult er = null;
    String sql = "SELECT politician_president.id, party.name "
               + "FROM country "
               + "JOIN politician_president ON country.id = politician_president.country_id "
               + "JOIN party ON politician_president.party_id = party.id "
               + "WHERE country.name = '" + countryName + "' ORDER BY politician_president.start_date DESC;";
    // Write the sql
    try {
      PreparedStatement execStat = connection.prepareStatement(sql);
      ResultSet result = execStat.executeQuery();
      while (result.next()) {
        // Retrieve by column index
        int id = result.getInt(1);
        String partyName = result.getString(2);
        presidentsList.add(id);
        partyNamesList.add(partyName);
      }
      er = new ElectionResult(presidentsList, partyNamesList);
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("SQL Exception");
    }
    return er;
  }

  @Override
  /**
   * Given a party id, returns other parties that have similar descriptions in the database
   * 
   * @param partyId: the id of a party
   * @param threshold: a float point number that can be threshold
   * @return null
   */
  public List<Integer> findSimilarParties(Integer partyId, Float threshold) {
    // A list of findSimilarParties
    List<Integer> finalList = new ArrayList<Integer>();
    // Write the sql
    String sql;
    sql = "SELECT p2.id AS Party2_id, "
        + "p1.description AS P1_Des, p2.description AS P2_Des "
        + "FROM party p1, party p2 "
        + "WHERE p1.id = " + partyId + " AND p1.id != p2.id;";
    try {
      // from id find name find description
      PreparedStatement execStat = connection.prepareStatement(sql);
      ResultSet rs = execStat.executeQuery();
      while (rs.next()) {
        // Retrieve by column index
        Integer p2ID = rs.getInt(1);
        String p1Des = rs.getString(2);
        String p2Des = rs.getString(3);
        Double score = similarity(p1Des, p2Des);
        if (score >= threshold) {
          finalList.add((Integer) p2ID);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("SQL Exception");
    }
    return finalList;
  }

  public static void main(String[] args) throws Exception {
    // Write code here.
    // TEST BLOCK START <-------------------------------------------------------------------

    // JDBCSubmission a3 = new Assignment3();
    // a3.connectDB(url, username, password);
    // a3.presidentSequence(countryName);
    // a3.findSimilarParties(partyID, threshold);
    // a3.disconnectDB();

    // TEST BLOCK END <---------------------------------------------------------------------
    System.out.println("Hellow World");
  }

}
