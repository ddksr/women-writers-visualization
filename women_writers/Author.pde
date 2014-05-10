import java.util.LinkedList;
import java.util.Map;

class Author {
  public String name, country, language;
  public int yBirth, yDeath;
  public LinkedList<Work> works;
  public LinkedList<Receptor> receptors;

  public int yFirstMention = Integer.MAX_VALUE,
    yFirstClass = Integer.MAX_VALUE, yLastClass = Integer.MIN_VALUE;
  
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

  public int age() {
    return yBirth > 0 && yDeath > 0 ? (yDeath - yBirth) : 0;
  }
  
  public int getSizeParameter(int type) {
    switch(type) {
    case Globals.SIZE_OPTION_NUM_OF_RECEPTIONS:
      return numOfReceptions();
    case Globals.SIZE_OPTION_NUM_OF_WORKS:
      return numOfWorks();
    case Globals.SIZE_OPTION_AGE:
      return age();
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
    case Globals.SIZE_OPTION_AGE:
      return charMode ? 40 : 50;
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
    case Globals.COLOR_OPTION_COUNTRY:
      return country;
    default:
      return majorityReceptorType;
    }
  }

  
  public HashMap<Integer, Integer> distYearWorks;
  public HashMap<Integer, Integer> distYearReceptions;
  public void prepareDistributions(int mode) {
    distYearWorks = new HashMap<Integer, Integer>();
    distYearReceptions = new HashMap<Integer, Integer>();
    
    for (Work w : works) {
      int year = w.year;
      if (year == 0) { continue; } // skip
      if (year < yFirstMention) { yFirstMention = year; }
      int yClass = Globals.yearToClass(year, mode);
      if (yClass < yFirstClass) { yFirstClass = yClass; }
      if (yClass > yLastClass) { yLastClass = yClass; }
      
      Integer classKey = new Integer(yClass);
      Integer val;
      if (distYearWorks.containsKey(classKey)) {
        val = new Integer(((Integer)distYearWorks.get(classKey)).intValue() + 1);
      }
      else {
        val = new Integer(1);
      }
      distYearWorks.put(classKey, val);
    }

    for (Receptor r : receptors) {
      int year = r.yReception;
      if (year == 0) { continue; } // skip
      
      int yClass = Globals.yearToClass(year, mode);
      if (yClass < yFirstClass) { yFirstClass = yClass; }
      if (yClass > yLastClass) { yLastClass = yClass; }
      Integer classKey = new Integer(yClass);
      Integer val;
      if (distYearReceptions.containsKey(classKey)) {
        val = ((Integer)distYearReceptions.get(classKey)).intValue();
        val = new Integer(val + 1);
      }
      else {
        val = new Integer(1);
      }
      distYearReceptions.put(classKey, val);
    }
  }

  
}
