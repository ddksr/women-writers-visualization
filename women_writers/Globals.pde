static class Globals {
  // Constants
  public static final int VIEW_MODE_CLOUD = 0, VIEW_MODE_INFO = 1;
  public static final int FRAME_WIDTH=1000, FRAME_HEIGHT=800;
  public static final int WORD_CLOUD_WIDTH=600, WORD_CLOUD_HEIGHT=600;
  public static final int VIEW_MODE_INFO_AUTHOR_PANEL_POSITION_Y = 150;
  public static final int VIEW_MODE_INFO_AUTHOR_PANEL_HEIGHT = 200;
  public static final int YEAR_DISTRIBUTION_MODE = 10;
  public static final int MIN_YEAR_RANGE = 40;
  
  // Size options
  public static String sizeOptionTitle = "Word size (# works)";
  public static String[] sizeOptions = {
    "# receptors", "# works", "Age"
  };
  public static final int SIZE_OPTION_NUM_OF_RECEPTIONS = 0,
    SIZE_OPTION_NUM_OF_WORKS = 1, SIZE_OPTION_AGE = 2;


  // Color options
  public static String colorOptionTitle = "Word color (country)";
  public static String[] colorOptions = {
    "Majority receptor type", "Majority work type",
    "Country"
  };
  public static final int COLOR_OPTION_RECEPTOR_TYPE = 0,
    COLOR_OPTION_WORK_TYPE = 1, COLOR_OPTION_COUNTRY = 2;

  // States
  public static HashMap<String, Author> authors;
  public static int viewMode = VIEW_MODE_CLOUD;
  public static boolean[] pressedChars = new boolean [26];
  public static int countAuthors = 0, countReceptions = 0, countWorks = 0;
  public static int sizeParameter = SIZE_OPTION_NUM_OF_WORKS;
  public static int colorParameter = COLOR_OPTION_COUNTRY;
  public static Author selectedAuthor;
  
  // Helpers
  public static boolean validChar(int c) {
    return c >=0 && c < 26;
  }
  public static int yearToClass(int year, int mode) {
    return year/mode*mode;
  }
}
