import wordcram.*;
import java.util.TreeSet;
import java.util.Map;

class ColorManager {
  public final int MAX_COLORS = 8;
  public int numColors = 0;
  //public final Color DEFAULT_COLOR = Color();

  class ColorElement implements Comparable<ColorElement> {
    public String value;
    public int count = 0;

    public ColorElement(String value, int count) {
      this.value = value;
      this.count = count;
    }
    
    @Override
    public int compareTo(ColorElement elt) {
      return -1 * Integer.compare(count, elt.count);
    }

    @Override
    public int hashCode() {
      return value.hashCode();
    }
  }

  
  public HashMap<String, Integer> map;
  public HashMap<String, Float> colors;
  public String[] legendValues = new String[MAX_COLORS + 1];
  public float[] legendColors = new float[MAX_COLORS + 1];

  public ColorManager() {
    map = new HashMap<String, Integer>();
    colors = new HashMap<String, Float>(MAX_COLORS);
  }

  public boolean add(String element, int weight) {
    int count;
    if (element == null) {
      return false;
    }
    if (map.containsKey(element)) {
      count = ((Integer)map.get(element)).intValue() + (weight+1);
    }
    else {
      count = (weight+1);
    }
    map.put(element, new Integer(count));
    return true;
  }

  public void generateColors() {
    TreeSet<ColorElement> tree = new TreeSet<ColorElement>();
    Iterator it = map.entrySet().iterator();
    while (it.hasNext()) {
        Map.Entry pairs = (Map.Entry)it.next();
        ColorElement e = new ColorElement((String)pairs.getKey(),
                                          ((Integer)pairs.getValue()).intValue());
        it.remove(); // avoids a ConcurrentModificationException
        tree.add(e);
    }

    it = tree.iterator();
    for (int i = 0; it.hasNext() && i < MAX_COLORS; i++) {
      ColorElement e = (ColorElement)it.next();
      float value = (float)i / MAX_COLORS;
      colors.put(e.value, new Float(value));
      legendColors[i] = value;
      legendValues[i] = e.value;
      numColors = i+1;
    }
    legendColors[numColors] = -1;
    legendValues[numColors] = new String("unknown");
  }

  public float getColor(String element) {
    if (colors.containsKey(element)) {
      return ((Float)colors.get(element)).floatValue();
    }
    else return -1;
  }

  public void clear() {
    map.clear();
    if (colors != null) { colors.clear(); }
  }
 
}
