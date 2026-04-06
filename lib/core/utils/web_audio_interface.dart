// Interface for web audio to avoid unconditional dart:html imports
abstract class WebAudioPlayer {
  void play();
  void stop();
  void dispose();
  set currentTime(double value);
  set volume(double value);
}

// WebAudioPlayer? createWebAudioPlayer(String src);
