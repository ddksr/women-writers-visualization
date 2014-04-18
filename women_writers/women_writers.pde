import java.util.Map;
import java.util.LinkedList;

import controlP5.*;

import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;


// Fields
MySQL conn;

boolean sqlConnect() {
  conn = new MySQL(this, Database.host, Database.database, Database.user, Database.pass);
  return conn.connect();
}

int getDbInt(String res) {
  try {
    if (res == null || res.length() == 0) return 0;
    return Integer.parseInt(res);
  }
  catch (Exception e) {
    println("!!! Not a year: " + res);
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
    Globals.countAuthors++;
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
      Globals.countWorks++;
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
      Globals.countReceptions++;
    }
    else {
      countReceptionsErrors++;
    }
  }
  println(String.format("Authors: %d", Globals.countAuthors));
  println(String.format("Works: %d vs %d (errors)", Globals.countWorks, countWorksErrors));
  println(String.format("Receptions: %d vs %d (errors)", Globals.countReceptions, countReceptionsErrors));
}

ControlP5 cp5;
ControlWindow controlWindow;
Canvas cc;
// MyCanvas, your Canvas render class
class MyCanvas extends Canvas {

  int y;

  public void setup(PApplet theApplet) {
    y = 200;
  }  

  public void draw(PApplet p) {
    // Set up the Processing sketch
p.size(1000, 600);
p.colorMode(HSB);
p.background(230);

// Make a wordcram from a random wikipedia page.
new WordCram(p)
  .fromWebPage("http://en.wikipedia.org/wiki/Special:Random")
  .withColors(color(30), color(110),
              color(random(255), 240, 200))
  .sizedByWeight(5, 120)
  .withFont("Copse")
  .drawAll();
  }
}

import wordcram.*;



void draw() {
  background(0);
  fill(60);
  rect(100, 100, 200, 200);
}

void setup() {
  Globals.authors = new HashMap<String, Author>();
  if (sqlConnect()) {
    prepareData(Globals.authors);
  }
  
  size(1000, 1000);
  frameRate(30);
  cp5 = new ControlP5(this);

  // create a control window canvas and add it to
  // the previously created control window.  
  cc = new MyCanvas();
  cc.pre(); // use cc.post(); to draw on top of existing controllers.
  cp5.addCanvas(cc); // add the canvas to cp5
}
