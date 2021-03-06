import g4p_controls.*;

import ddf.minim.*;

boolean shiftPressed, controlPressed, altPressed, showHelpText;
Minim minim;
TrackSequencer sequencer;
JSONManager jsonManager;

int previousMouseButton;


boolean up = false;
boolean down = false;
boolean left = false;
boolean right = false;

boolean playing = false;

String soundfilePath = "data\\60BPM_Stereo_ClickTrack.wav";
float bpm = 60;

int type = 0;
    
int helpboxX, helpboxY, helpboxSize;

String[] helpText = {
  "  SPACE:                 Play / Pause",
  "  SHIFT+SPACE:  Jump to start",
  "",
  "  Place RED note : Left click", 
  "  Place BLUE note: Right click",
  "                              or: Control + Left Click",
  "  Place MINE : Middle click",
  "                              or: Alt + Left Click",
  "  Delete note: Shift + Left Click",
  "",
  "  SCROLL WHEEL: Scroll Up / Down",
  "  SHIFT + SCROLL WHEEL: Scroll faster",
  "",
  "  Directional arrows:",
  "  W: Up",
  "  S: Down",
  "  A: Left",
  "  D: Right",
  "  For diagonals, combine buttons.",
  "  W+A = UP LEFT, W+D = UP RIGHT, etc",
  "",
  "  Tab: Hide / show guide",
  "",
  "  To exit, click the square stop button",
  "  in processing."};

GTextField bpmTextField;

// Controls used for file dialog GUI 
GButton btnFolder, btnOpenSong, btnInput, btnOutput;
GLabel lblFile;

void setup(){
  size(1280, 720);
  noSmooth();
  stroke(0);
  background(0);
  
  shiftPressed = false;
  controlPressed = false;
  altPressed = false;
  showHelpText = true;
  
  // This needs to be in the main class
  minim = new Minim(this);
  
  int seqOffsetY = 200;
  sequencer = new TrackSequencer(0, height, width, -height, minim);
  
  sequencer.loadSoundFile(soundfilePath);
  sequencer.setBPM(bpm);
  
  jsonManager = new JSONManager(sequencer);
  
  helpboxSize = 350;
  helpboxX = width - 350;
  helpboxY = 150;
  
  createFileSystemGUI(width - 350, 0, 350, 130, 6);
}

void draw(){
  // Redraw background
  background(#111111);
  
  sequencer.setCutDirection(getNewCutDirection());
  
  sequencer.display();
  
  fill(0);
  stroke(0);
  // Draw help text
  if(showHelpText){
    
    rect(helpboxX, 0, helpboxSize, height);
    
    textSize(12);
    fill(#ffffff);
    text("GUIDE", helpboxX + 10, 15);
    
    int helpIndex = 0;
    int helpIndexSpacing = 20;
    for(String s : helpText){
      ++helpIndex;
      text(s, helpboxX + 10, helpboxY + 15 + helpIndex * helpIndexSpacing);
    }
  }
  
}

void mousePressed(){
  checkClick();
}

void mouseDragged(){
  checkClick();
}

void mouseReleased(){
  
}

void checkClick(){
  int type = 0;
  
  if(shiftPressed){
    type = -1;
  }else if(mouseButton == LEFT){
    if(controlPressed)
      type = Note.TYPE_BLUE;
    else if(altPressed)
      type = Note.TYPE_MINE;
    else
      type = Note.TYPE_RED;
  }else{
    type = sequencer.getTypeFromMouseButton(mouseButton);
  }
  sequencer.checkClickedTrack(mouseX, mouseY, type);
  
  // Processing doesn't store what button was released,
  // so I have to do this
  previousMouseButton = mouseButton;
  
  if(!sequencer.getPlaying()){
    sequencer.setTrackerPosition(mouseY);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(shiftPressed){
    sequencer.scrollY(-e * 10);
  }else{
    sequencer.scrollY(-e);
  }
}

void keyPressed(){
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftPressed = true;
    }
    if (keyCode == CONTROL) {
      controlPressed = true;
    }
    if (keyCode == ALT) {
      altPressed = true;
    }
  }
  
  if(key == ' '){
    if(shiftPressed){
      sequencer.stop();
    }else{
      if(sequencer.getPlaying())
        sequencer.setPlaying(false);
      else
        sequencer.setPlaying(true);
    }
  }
  
  if(key == 'w'){
    up = true;
  }if(key == 's'){
    down = true;
  }if(key == 'a'){
    left = true;
  }if(key == 'd'){
    right = true;
  }
}

void keyReleased(){
  if(key == 'w'){
    println("Released W");
    up = false;
  }if(key == 's'){
    down = false;
  }if(key == 'a'){
    left = false;
  }if(key == 'd'){
    right = false;
  }
  
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftPressed = false;
    }
    if (keyCode == CONTROL) {
      controlPressed = false;
    }
    if (keyCode == ALT) {
      altPressed = false;
    }
  }
  
  switch(key){
    case TAB:
      if(showHelpText)
        showHelpText = false;
      else
        showHelpText = true;
      break;
    default:
      break;
  }
}

public int getNewCutDirection(){
  int dir = 8;
  if(up)
    dir = Note.DIR_BOTTOM;
  if(down)
    dir = Note.DIR_TOP;
  if(left)
    dir = Note.DIR_RIGHT;
  if(right)
    dir = Note.DIR_LEFT;
    
  if(up && left)
    dir = Note.DIR_BOTTOMRIGHT;
  else if(up && right)
    dir = Note.DIR_BOTTOMLEFT;
  else if(down && left)
    dir = Note.DIR_TOPRIGHT;
  else if(down && right)
    dir = Note.DIR_TOPLEFT;

  return dir; 
}

public void displayEvent(String name, GEvent event) {
  String extra = " event fired at " + millis() / 1000.0 + "s";
  print(name + "   ");
  switch(event) {
  case CHANGED:
    println("CHANGED " + extra);
    break;
  case SELECTION_CHANGED:
    println("SELECTION_CHANGED " + extra);
    break;
  case LOST_FOCUS:
    println("LOST_FOCUS " + extra);
    break;
  case GETS_FOCUS:
    println("GETS_FOCUS " + extra);
    break;
  case ENTERED:
    println("ENTERED " + extra);  
    break;
  default:
    println("UNKNOWN " + extra);
  }
}

public void handleTextEvents(GEditableTextControl textControl, GEvent event) { 
  displayEvent(textControl.tag, event);
  
  if (textControl.tag.equals(bpmTextField.tag)){
  switch(event) {
    case ENTERED:
        sequencer.setBPM(float(bpmTextField.getText()));
      break;
    }
  }
}

public void handleButtonEvents(GButton button, GEvent event) { 
  // Folder selection
  if (button == btnOpenSong || button == btnInput || button == btnOutput)
    handleFileDialog(button);
}

// G4P code for folder and file dialogs
public void handleFileDialog(GButton button) {
  String fname;
  // File input selection
  if (button == btnOpenSong) {
    // Use file filter if possible
    fname = G4P.selectInput("Input Dialog", "wav,mp3,aiff", "Sound files");
    lblFile.setText(fname);
    sequencer.loadSoundFile(fname);
  }
  // File output selection
  else if (button == btnInput) {
    fname = G4P.selectInput("Input Dialog");
    lblFile.setText(fname);
    jsonManager.loadTrack(fname);
  }
  // File output selection
  else if (button == btnOutput) {
    fname = G4P.selectOutput("Output Dialog");
    lblFile.setText(fname);
    jsonManager.saveTrack(fname);
  }
}


public void createFileSystemGUI(int x, int y, int w, int h, int border) {
  // Set inner frame position
  x += border; 
  y += border;
  w -= 2*border;
  h -= 2*border;
  GLabel title = new GLabel(this, x, y, w, 20);
  title.setText("Beat Saber Unofficial Track Editor", GAlign.LEFT, GAlign.MIDDLE);
  title.setOpaque(true);
  title.setTextBold();
  // Create buttons
  int bgap = 8;
  int bw = round((w - 3 * bgap) / 4.0f);
  int bs = bgap + bw;
  btnOpenSong = new GButton(this, x, y+30, bw, 20, "Load Audio");
  btnInput = new GButton(this, x+2*bs, y+30, bw, 20, "Load Track");
  btnOutput = new GButton(this, x+3*bs, y+30, bw, 20, "Save Track");
  
  bpmTextField = new GTextField(this, x+bs, y+30, bw, 20);
  bpmTextField.tag = "bpmText";
  bpmTextField.setPromptText("BPM");
  
  lblFile = new GLabel(this, x, y+60, w, 60);
  lblFile.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  lblFile.setOpaque(true);
  lblFile.setLocalColorScheme(G4P.BLUE_SCHEME);
}
