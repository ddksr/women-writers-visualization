static class Globals {
  // Constants
  public static final int VIEW_MODE_CLOUD = 0, VIEW_MODE_INFO = 1;
  public static final int FRAME_WIDTH=1000, FRAME_HEIGHT=800;
  public static final int WORD_CLOUD_WIDTH=600, WORD_CLOUD_HEIGHT=600;
  // States
  public static HashMap<String, Author> authors;
  public static int countAuthors = 0, countWorks = 0, countReceptions = 0;
  public static int viewMode = VIEW_MODE_CLOUD;
  public static boolean[] pressedChars = new boolean [26];

  // Helpers
  public static boolean validChar(int c) {
    return c >=0 && c < 26;
  }
}
