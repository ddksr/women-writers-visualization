import java.util.Map;
import java.util.LinkedList;

import controlP5.*;

import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;



// Fields
MySQL conn;
HashMap<String, Author> authors;
int countAuthors = 0, countWorks = 0, countReceptions = 0;

boolean sqlConnect() {
  conn = new MySQL( this, "delphi.fri.uni-lj.si:3306", database, user, pass );
  return conn.connect();
}

int getDbInt(String res) {
  try {
    if (res == null || res.length() == 0) return 0;
    return Integer.parseInt(res);
  }
  catch (Exception e) {
    println(res);
    return 0;
  }
}

void prepareData(HashMap<String, Author> tbl) {
  int countWorksErrors=0, countReceptionsErrors=0;
  conn.query( "SELECT * FROM avtorice2;" );
  while (conn.next()) {
    Author a = new Author();
    a.name = conn.getString("ime");
    a.yBirth = getDbInt(conn.getString("leto_rojstva"));
    a.yDeath = getDbInt(conn.getString("leto_smrti"));
    a.country = conn.getString("drzava");
    a.language = conn.getString("jezik");
    tbl.put(a.name, a);
    countAuthors++;
  }
  conn.query( "SELECT * FROM dela;" );
  while (conn.next()) {
    Work w = new Work();
    w.name = conn.getString("ime");
    w.year = getDbInt(conn.getString("leto"));
    w.type = conn.getString("zanr");
    w.country = conn.getString("drzava");
    Author a = tbl.get(w.name);
    if (a != null) {
      a.works.add(w);
      countWorks++;
    }
    else {
      countWorksErrors++;
    }
  }
  conn.query( "SELECT * FROM avtorice;");
  while (conn.next()) {
    Receptor r = new Receptor();
    
    r.name = conn.getString("ime");
    r.title = conn.getString("naslov");
    r.receptor = conn.getString("receptor");
    r.gender = conn.getString("spol") != null ? conn.getString("spol").charAt(0) : null;
    r.type = conn.getString("tip");
    r.yPublish = getDbInt(conn.getString("leto_izdaje"));
    r.yReception = getDbInt(conn.getString("leto_recepcije"));
    r.countryPublish = conn.getString("drzava_izdaje");
    r.countryReception = conn.getString("drzava_recepcije");
    
    Author a = tbl.get(r.name);
    if (a != null) {
      a.receptors.add(r);
      countReceptions++;
    }
    else {
      countReceptionsErrors++;
    }
  }
  println(String.format("Authors: %d", countAuthors));
  println(String.format("Works: %d vs %d (errors)", countWorks, countWorksErrors));
  println(String.format("Receptions: %d vs %d (errors)", countReceptions, countReceptionsErrors));
}

void setup() {
  authors = new HashMap<String, Author>();
  if (sqlConnect()) {
    prepareData(authors);
  }
}
void draw() {

}
