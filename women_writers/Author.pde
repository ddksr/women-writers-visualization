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
    return receptors.size();
  }

  public int numOfWorks() {
    return works.size();
  };
  
  public int sizeParameter(int type) {
    switch(type) {
    case Globals.SIZE_OPTION_NUM_OF_RECEPTIONS:
      return numOfReceptions();
    case Globals.SIZE_OPTION_NUM_OF_WORKS:
      return numOfWorks();
    default:
      return numOfReceptions();
    }
  }

  public int minSizeParameter(int type) {
    switch(type) {
    case Globals.SIZE_OPTION_NUM_OF_RECEPTIONS:
      return 5;
    case Globals.SIZE_OPTION_NUM_OF_WORKS:
      return 5;
    default:
      return 5;
    }    
  }
}
