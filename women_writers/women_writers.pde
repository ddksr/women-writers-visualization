import java.util.Map;
import java.util.LinkedList;
import java.util.Iterator;
import controlP5.*;
import java.util.List;


import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

import wordcram.*;

// Fields
MySQL conn;
Word[] words = null;
//words to display on current selection
Word[] toDisplay = null;
WordCram wc = null;

// ControlP5
ControlP5 cp5;
ControlWindow controlWindow;
Canvas cc;
DropdownList d1, d2;

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

void draw() {
  if (Globals.viewMode == Globals.VIEW_MODE_CLOUD) {
    if (words == null) {        
      prepareWords();
    }
    if (wc == null) {
      initWordCloud();
    }
    drawWordCloud(10);

  }
  else if (Globals.viewMode == Globals.VIEW_MODE_INFO) {
    // show author info
    
  }
  clear(); // currently important but maybe we won't need it
  // because we will redraw the cloud when a dropdown changes
}

void clear() {
  // We cannot draw the word cloud everytime but we have
  // to somehow clear ControlP5 ... so we clear it with
  // a rect that has the same color as the background
  // and WOLA, MAGIC, works
  
  fill(230);
  noStroke();
  rectMode(CORNER);
  rect(0, 0, Globals.FRAME_WIDTH, 150);
}

void setup() {
  Globals.authors = new HashMap<String, Author>();
  if (sqlConnect()) {
    prepareData(Globals.authors);
  }
  
  size(Globals.FRAME_WIDTH, Globals.FRAME_HEIGHT);
  frameRate(30);
  
  gui();
  //smooth();
}

void gui() {
  cp5 = new ControlP5(this);
  
  DropdownList d2 = cp5.addDropdownList("myList-d2")
    .setPosition(10, 20)
    .setSize(150, 100) // this somehow also influences the open dropdown size (NOTE: somehow)
    ;
  customize(d2);
  d2.setIndex(10);
}

void prepareWords() {
  Iterator it;
  int valid = 0;
  LinkedList<Word> authors = new LinkedList<Word>();   
  it = Globals.authors.entrySet().iterator();
  for (int i = 0; it.hasNext(); i++) {
    Map.Entry pairs = (Map.Entry)it.next();
    Author a = (Author)pairs.getValue();
    int val = a.count("something")+1;
    if (val > 5) {
      authors.add(new Word(a.name, val));
      valid++;
    }        
  }
  println("Valid for cloud: " + valid);
  words = new Word[valid];
  it = authors.iterator();
  for (int i = 0; it.hasNext(); i++) {
    words[i] = (Word)it.next();
  }
}
public List<Word> getAuthors (char character){
  //method for filtering authors whose name/surname begins with character
  List<Word> list = new LinkedList<Word>();
  for (Word w : words){
    char firstChar = w.toString().charAt(0);
    if (firstChar == character){
      list.add(w);
    }
  }
   return list;
}
void initWordCloud() {
  colorMode(HSB);
  background(230);
  //get values from checkbox - todo, for now = 'A'
  List<Word> f = getAuthors ('A');
  //convert from linked list to table...(.fromWords dosn't accept linked lists...)
  Word[] toDisplay = new Word[f.size()];
  int c = 0;
  for (Word t : f){
    toDisplay[c] = t;
    c++;
  }
  wc = new WordCram(this)
    .fromWords(toDisplay)
    .withColors(color(30), color(110),
                color(random(255), 240, 200))
    .sizedByWeight(5, 120)
    .withFont("Copse");
}

void drawWordCloud(int n) {
  for (int i = 0; i < n; i++) {
    if (wc.hasMore()) {
      wc.drawNext();
    }
  }
}

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(15);
  ddl.setBarHeight(15);
  ddl.captionLabel().set("dropdown");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  for (int i=0;i<10;i++) {
    ddl.addItem("item "+i, i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}
