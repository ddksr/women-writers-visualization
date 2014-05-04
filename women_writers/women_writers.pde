import java.util.Map;
import java.util.LinkedList;
import java.util.Iterator;
import controlP5.*;
import java.util.List;


import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

import wordcram.*;

// Fields
boolean clear = true;
boolean loading = true;
boolean legend = false;
MySQL conn;
Word[] words = null;
//words to display on current selection
Word[] toDisplay = null;
WordCram wc = null;
ColorManager colors = new ColorManager();
//checkbox for alphabet
CheckBox checkbox;
char[] alphabet = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};

// ControlP5
ControlP5 cp5;
ControlWindow controlWindow;
Canvas cc;
Group groupAuthorInfo;
DropdownList ddSize, ddColor;
Textlabel aiTitle, aiCountryLanguage;

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

  Iterator it = tbl.entrySet().iterator();
  while (it.hasNext()) {
    Map.Entry pairs = (Map.Entry)it.next();
    Author a = (Author)pairs.getValue();
    a.initColorParams();
  }

  initWordColors();
  
  println(String.format("Authors: %d", Globals.countAuthors));
  println(String.format("Works: %d vs %d (errors)", Globals.countWorks, countWorksErrors));
  println(String.format("Receptions: %d vs %d (errors)", Globals.countReceptions, countReceptionsErrors));
  
}

void draw() {
  if (loading) {
    PFont font = createFont("Arial", 50,true); 
    background(230);
    textAlign(CENTER);
    textFont(font);
    fill(0);
    text("Loading ... ", Globals.FRAME_WIDTH / 2, Globals.FRAME_HEIGHT / 2);

    loading = false;
  }
  else if (Globals.viewMode == Globals.VIEW_MODE_CLOUD) {
    if (words == null) {        
      prepareWords();
    }
    if (wc == null) {
      initWordCloud();
      groupAuthorInfo.hide();
    }
    drawWordCloud(10);
    if (mouseY > 150 && mouseY < (Globals.FRAME_HEIGHT - 100)) {
      cursor(HAND);
    } else {
      cursor(ARROW);
    }
  }
  else if (Globals.viewMode == Globals.VIEW_MODE_INFO) {
    if (Globals.selectedAuthor != null) {
      Author a = Globals.selectedAuthor;
      Globals.selectedAuthor = null;
      resetView();
      cursor(ARROW);
      colorMode(HSB);
      background(230);
      groupAuthorInfo.show();
      aiTitle.setText(a.name);
      String countryLanguage = new String(a.country != null ? a.country : "Country unknown");
      countryLanguage += ", ";
      countryLanguage += a.language != null ? a.language : "Language unknown";
      

      String life = new String("");
      if (a.yBirth > 0) { life = new String("* " + a.yBirth); }
      if (a.yBirth > 0 && a.yDeath > 0) {
        life += new String(" † " + a.yBirth);
      }
      else if (a.yDeath > 0) {
        life = new String("* unknown † " + a.yBirth);
      }
      else if (a.yDeath == 0) {
        life = new String("Born " + life.substring(2));
      }
      else {
        life = new String("Year of birth and death unknown");
      }
      if (life.length() > 0) { life = ", " + life; }
      aiCountryLanguage.setText(countryLanguage + life);

    }
  }
  
  clear(); // currently important but maybe we won't need it
  // because we will redraw the cloud when a dropdown changes
}

void clear() {
  // We cannot draw the word cloud everytime but we have
  // to somehow clear ControlP5 ... so we clear it with
  // a rect that has the same color as the background
  // and WOLA, MAGIC, work
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
  
  ddSize = cp5.addDropdownList("size")
    .setPosition(10, 20)
    .setSize(150, 100) // this somehow also influences the open dropdown size (NOTE: somehow)
    ;
  customizeDropdown(ddSize, Globals.sizeOptionTitle, Globals.sizeOptions);
  ddSize.setIndex(10);

  ddColor = cp5.addDropdownList("color")
    .setPosition(160, 20)
    .setSize(150, 100) // this somehow also influences the open dropdown size (NOTE: somehow)
    ;
  customizeDropdown(ddColor, Globals.colorOptionTitle, Globals.colorOptions);
  ddSize.setIndex(10);
  
  checkbox = cp5.addCheckBox("checkBox")
    .setPosition(600, 20)
    .setColorForeground(color(120))
    .setColorActive(color(200))
    .setColorLabel(color(50))
    .setSize(20, 20)
    .setItemsPerRow(13)
    .setSpacingColumn(20)
    .setSpacingRow(20);
  for (int i = 0; i < 26; i++) {
    checkbox.addItem(alphabet[i] + "", i);
  }

  groupAuthorInfo = cp5.addGroup("g2")
    .setPosition(0,150)
    .setWidth(Globals.FRAME_WIDTH)
    .activateEvent(true)
    .setBackgroundColor(color(230))
    .setBackgroundHeight(Globals.FRAME_HEIGHT - 170)
    .setLabel("Author info")
    .hide()
    .hideBar()
    ;
  authorInfoGui();
}

void authorInfoGui() {
  cp5.addButton("aiButtonClose")
    .setPosition(Globals.FRAME_WIDTH - 40,10)
    .setSize(30,19)
    .setLabel("Close")
    .setGroup(groupAuthorInfo)
    ;
  aiTitle = cp5.addTextlabel("authorName")
    .setPosition(10, 10)
    .setColor(color(30))
    .setText("Author")
    .setFont(createFont("Copse", 26))
    .setGroup(groupAuthorInfo)
    ;
  aiCountryLanguage = cp5.addTextlabel("authorCountry")
    .setPosition(10, 50)
    .setColor(color(30))
    .setText("Country")
    .setFont(createFont("Copse", 20))
    .setGroup(groupAuthorInfo)
    ;

}

void aiButtonClose() {
  resetView();
  Globals.viewMode = Globals.VIEW_MODE_CLOUD;
  groupAuthorInfo.hide();
  
}

// for word cloud
void mouseClicked() {
  if (wc != null) {
    Word word = wc.getWordAt(mouseX, mouseY);
    if (word != null) {
      Globals.selectedAuthor = (Author)word.getProperty("info");
      Globals.viewMode = Globals.VIEW_MODE_INFO;
    }
  }
}

//for checkbox
void keyPressed() {
  if (key==' ') {
    checkbox.deactivateAll();
  } 
  else {
    for (int i=0;i<6;i++) {
      // check if key 0-5 have been pressed and toggle
      // the checkbox item accordingly.
      if (keyCode==(48 + i)) { 
        // the index of checkbox items start at 0
        checkbox.toggle(i);
        println("toggle "+checkbox.getItem(i).name());
        // also see 
        // checkbox.activate(index);
        // checkbox.deactivate(index);
      }
    }
  }
}

void controlEvent(ControlEvent theEvent) {
  char newC = ' ';
  //problem: when event is triggered, we have to redraw the whole thing
  if (theEvent.isFrom(checkbox)) {
    print("got an event from "+checkbox.getName()+"\t\n");
    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    //println(checkbox.getArrayValue());
    int col = 0;
    for (int i=0;i<checkbox.getArrayValue().length;i++) {
      int h = (int)checkbox.getArrayValue()[i];
      if (h == 1){
        newC = alphabet[i];
        Globals.pressedChars[i] = true;
      }
      else {
        Globals.pressedChars[i] = false;
      }
      print(h);
    }
    println();
    println(String.format("Characetrs to add: %c", newC));
    resetView();
  }
  if(theEvent.isFrom(ddSize)) {
    if (theEvent.isGroup()) {
      Globals.sizeParameter = (int)theEvent.getGroup().getValue();
    } 
    else if (theEvent.isController()) {
      Globals.sizeParameter = (int)theEvent.getController().getValue();
    }
    resetView();
  }
  if(theEvent.isFrom(ddColor)) {
    if (theEvent.isGroup()) {
      Globals.colorParameter = (int)theEvent.getGroup().getValue();
    } 
    else if (theEvent.isController()) {
      Globals.colorParameter = (int)theEvent.getController().getValue();
    }
    initWordColors();
    resetView();
  }
}

void resetView() {
  loading = true;
  words = null;
  legend = false;
}

void prepareWords() {
  Iterator it;
  int valid = 0;
  LinkedList<Word> authors = new LinkedList<Word>();   
  it = Globals.authors.entrySet().iterator();
  boolean charsMarked = charsMarked();
  colorMode(HSB);
  for (int i = 0; it.hasNext(); i++) {
    Map.Entry pairs = (Map.Entry)it.next();
    Author a = (Author)pairs.getValue();
    int val = a.getSizeParameter(Globals.sizeParameter);
    if (val > a.minSizeParameter(Globals.sizeParameter, charsMarked)) {
      Word newWord = new Word(a.name, val);
      String param = a.getColorParameter(Globals.colorParameter);
      float hue = 255*colors.getColor(param);
      newWord.setColor(color(hue >= 0 ? hue : 0,
                             255*1.0, hue < 0 ? 0.0 : 255*0.5));
      newWord.setProperty("info", a);
      authors.add(newWord);
      valid++;
    }        
  }
  println("Valid for cloud: " + valid);
  words = new Word[valid];
  it = authors.iterator();
  for (int i = 0; it.hasNext(); i++) {
    words[i] = (Word)it.next();
  }
  wc = null; // clear word cloud
}
public List<Word> getAuthors (){
  //method for filtering authors whose name/surname begins with characters
  List<Word> list = new LinkedList<Word>();
  boolean charsMarked = charsMarked();
  for (Word w : words){
    char firstChar = w.toString().charAt(0);
    int charVal = (int)firstChar - 65;
    boolean valid = Globals.validChar(charVal) && Globals.pressedChars[charVal];
    if (valid || !charsMarked){
      list.add(w);
    }

  }
   return list;
}

boolean charsMarked() {
  for (int i = 0; i < 26; i++) {
    if (Globals.pressedChars[i]) { return true; }
  }
  return false;
}

void initWordCloud() {
  colorMode(HSB);
  background(230);

  List<Word> f = getAuthors ();
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
  if (! legend) {
    drawLegend();
    legend = true;
  }
  for (int i = 0; i < n; i++) {
    if (wc.hasMore()) {
      wc.drawNext();
    }
  }
}

void initWordColors() {
  colors.clear();
  Iterator it = Globals.authors.entrySet().iterator();
  while (it.hasNext()) {
    Map.Entry pairs = (Map.Entry)it.next();
    Author a = (Author)pairs.getValue();
    colors.add(a.getColorParameter(Globals.colorParameter),
               a.getSizeParameter(Globals.sizeParameter));
  }
  colors.generateColors();
  legend = false;
}

void drawLegend() {
  int xOffset = 10, yOffset = -20;
  boolean newRow = false;
  for (int i = 0; i < colors.numColors; i++) {
    if (i%3 == 0) { xOffset = 10; yOffset += 20; }
    drawLegendElement(xOffset, yOffset,
                      colors.legendColors[i], colors.legendValues[i]);
    xOffset += 300; //(20 + 8 * colors.legendValues[i].length());
  }
  if (colors.numColors % 3 == 0) { xOffset = 10; yOffset += 20; }
  drawLegendElement(xOffset, yOffset,
                    colors.legendColors[colors.numColors],
                    colors.legendValues[colors.numColors]);
}

void drawLegendElement(int xOffset, int yOffset,
                       float hueValue, String valueName) {
  int y = Globals.FRAME_HEIGHT - 70 + yOffset;
  colorMode(HSB);
  rectMode(CORNER);
  stroke(1);
  if (hueValue < 0) {
    fill(0, 255, 0);
  }
  else {
    fill(255*hueValue, 255*1.0, 255*0.5);
  }
  rect(xOffset, y, 14, 14);

  
  textAlign(LEFT);
  textFont(createFont("Copse", 12));
  text(valueName, xOffset + 20, y + 12);
}

void customizeDropdown(DropdownList ddl, String title, String[] options) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(15);
  ddl.setBarHeight(15);
  ddl.captionLabel().set(title);
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  for (int i=0; i<options.length; i++) {
    ddl.addItem(options[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}
