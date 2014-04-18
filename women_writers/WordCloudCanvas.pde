import controlP5.*;
import java.util.Iterator;
import wordcram.*;

// MyCanvas, your Canvas render class
class WordCloudCanvas extends Canvas {
  int test;

  public void setup(PApplet theApplet) {
    test = 0;
  }  

  public void draw(PApplet p) {
    // Set up the Processing sketch
    p.size(1000, 600);
    p.colorMode(HSB);
    p.background(230);
    
    Word[] authors = new Word[Globals.authors.size()];
    Iterator it = Globals.authors.entrySet().iterator();
    for (int i = 0; it.hasNext(); i++) {
        Map.Entry pairs = (Map.Entry)it.next();
        Author a = (Author)pairs.getValue();
        authors[i] = new Word(a.name, a.count("something")+1);
    }
    // Make a wordcram from a random wikipedia page.
    new WordCram(p)
//      .fromWebPage("http://en.wikipedia.org/wiki/Special:Random")
//      .fromWebPage("http://www.euronews.com/2014/04/18/protesters-clash-with-police-in-algeria-over-bouteflika-s-re-election-bid/")
      .fromWords(authors)
      .withColors(color(30), color(110),
                  color(random(255), 240, 200))
      .sizedByWeight(5, 120)
      .withFont("Copse")
      .drawAll();
      
  }
}
