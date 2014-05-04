import java.util.LinkedList;
import java.util.Map;

class Author {
  public String name, country, language;
  public int yBirth, yDeath;
  public LinkedList<Work> works;
  public LinkedList<Receptor> receptors;

  public String majorityReceptorType, majorityWorkType;
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
  
  public int getSizeParameter(int type) {
    switch(type) {
    case Globals.SIZE_OPTION_NUM_OF_RECEPTIONS:
      return numOfReceptions();
    case Globals.SIZE_OPTION_NUM_OF_WORKS:
      return numOfWorks();
    default:
      return numOfReceptions();
    }
  }

  public int minSizeParameter(int type, boolean charMode) {
    switch(type) {
    case Globals.SIZE_OPTION_NUM_OF_RECEPTIONS:
      return charMode ? 4 : 7;
    case Globals.SIZE_OPTION_NUM_OF_WORKS:
      return charMode ? 4 : 7;
    default:
      return charMode ? 4 : 7;
    }    
  }

  public void initColorParams() {
    HashMap<String, Integer> types = new HashMap<String, Integer>();
    int majVal = Integer.MIN_VALUE;
    for (Receptor r : receptors) {
      int count;
      if (! types.containsKey(r.type)) {
        types.put(r.type, new Integer(1));
        count = 1;
      }
      else {
        count = ((Integer)types.get(r.type)).intValue() + 1;
        types.put(r.type, new Integer(count));
      }
      if (count > majVal) {
        majVal = count;
        majorityReceptorType = r.type;
      }
    }
    types.clear();
    majVal = Integer.MIN_VALUE;
    for (Work w : works) {
      int count;
      if (! types.containsKey(w.type)) {
        types.put(w.type, new Integer(1));
        count = 1;
      }
      else {
        count = ((Integer)types.get(w.type)).intValue() + 1;
        types.put(w.type, new Integer(count));
      }
      if (count > majVal) {
        majVal = count;
        majorityWorkType = w.type;
      }
    }
  }
  
  public String getColorParameter(int type) {
    switch(type) {
    case Globals.COLOR_OPTION_RECEPTOR_TYPE:
      return majorityReceptorType;
    case Globals.COLOR_OPTION_WORK_TYPE:
      return majorityWorkType;
    default:
      return majorityReceptorType;
    }
  }
}
