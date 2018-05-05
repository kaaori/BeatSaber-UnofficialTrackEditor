class JSONManager{
  TrackSequencer seq;
  String outputFile, inputFile;
  JSONObject json;
  JSONArray events, notes, obstacles;
  
  String versionString = "1.5.0";
  int beatsPerBar = 16;
  int notesPerBar = 1; // Change this value later
  
  
  public JSONManager(TrackSequencer seq){
    this.seq = seq;
  }
  
  public void saveTrack(String filename){
    if(filename == null){
      println("Filename was null!");
      return;
    }
    this.outputFile = filename;
    
    json = new JSONObject();
    
    events = new JSONArray();
    notes = new JSONArray();
    obstacles = new JSONArray();
    
    setNotes();
    
    json.setString("_version", versionString);
    json.setFloat("_beatsPerMinute", seq.getBPM());
    json.setInt("_beatsPerBar", beatsPerBar);
    json.setFloat("_noteJumpSpeed", 10.0);
    json.setFloat("_shuffle", 0.0);
    json.setFloat("_shufflePeriod", 0.25);
    json.setJSONArray("_events", events);
    json.setJSONArray("_notes", notes);
    json.setJSONArray("_obstacles", obstacles);
    
    saveJSONObject(json, filename + ".json");
  }
  
  public void loadTrack(String filename){
    if(filename == null){
      println("Filename was null!");
      return;
    }
    clearTracks();
    json = loadJSONObject(filename);
    
    float bpmIn = json.getFloat("_beatsPerMinute");
    notes = json.getJSONArray("_notes");
    
    this.seq.setBPM(bpmIn);
    
    int trackCount = 0;
    int multiCount = 0;
    int noteCount = 0;
    
    int multiSize  = seq.multiTracks.size();
    int numTracks = seq.multiTracks.get(0).tracks.size();
    int trackSize = seq.multiTracks.get(0).tracks.get(0).trackSize;
    
    for(int i = 0; i < notes.size(); ++i){
      JSONObject note = notes.getJSONObject(i);
      
      float time    = note.getFloat("_time");
      int lineIndex = note.getInt("_lineIndex");
      int lineLayer = note.getInt("_lineLayer");
      int type      = note.getInt("_type");
      int cutDir    = note.getInt("_cutDirection");
      
      Track track = seq.multiTracks.get(multiSize - lineLayer - 1).tracks.get(numTracks - lineIndex - 1);
      
      Note newNote = new Note(track, 0, lineIndex, this.seq.getGridSize(), type, cutDir);
      
      println("time: " + time);
      /*
      track.gridBlocks[(int)((time * seq.getGridSize()))] = newNote;
      */
      //Note(GUIElement parent, int gridX, int gridY, int gridSize, int type, int cutDirection){
    }
    
  }
  
  private void setNotes(){
    // Go through every index in the track, but go across all tracks and get the current note
    int trackCount = 0;
    int multiCount = 0;
    int noteCount = 0;
    float beatsPerBar = seq.getBeatsPerBar();
    println("beatsPerBar:" + beatsPerBar);
    int trackSize = seq.multiTracks.get(0).tracks.get(0).trackSize;
    for(int i = 0; i < trackSize; ++i){
      multiCount = 0;
      for(MultiTrack m : seq.multiTracks){
        trackCount = 0;
        for(Track t : m.tracks){
          Note block = (Note)t.gridBlocks[i];
          if(block != null){
            JSONObject note = new JSONObject();
            
            println("Setting time to : " + block.getGridY() + " / " + beatsPerBar + " = " + (float)((block.getGridY())/beatsPerBar));
            note.setFloat("_time", (float)((block.getGridY())/beatsPerBar));
            note.setInt("_lineIndex", trackCount);
            note.setInt("_lineLayer", multiCount);
            note.setInt("_type", block.getType());
            note.setInt("_cutDirection", block.getCutDirection());
            
            notes.setJSONObject(noteCount, note);
            ++noteCount;
          }
          ++trackCount;
        }
        ++multiCount;
      }
    }
  }
  
  public void clearTracks(){
      for(MultiTrack m : seq.multiTracks){
        for(Track t : m.tracks){
          t.clearData();
        }
      }
      println("Cleared all tracks.");
  }
}
