import java.util.LinkedList;

class Author {
  public String name, country, language;
  public int yBirth, yDeath;
  public LinkedList<Work> works;
  public LinkedList<Receptor> receptors;
  public Author() {
    works = new LinkedList<Work>();
    receptors = new LinkedList<Receptor>();
  }
  String toString() {
    return name + " (" + country + ")";
  }
  
  public int numOfReceptions() {
    return works.size();
  }
  
  public int count(String type) {
    return numOfReceptions();
  }
}
