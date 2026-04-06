import 'web_audio_interface.dart';

class WebAudioPlayerStub implements WebAudioPlayer {
  @override
  void play() {}
  @override
  void stop() {}
  @override
  void dispose() {}
  @override
  set currentTime(double value) {}
  @override
  set volume(double value) {}
}

WebAudioPlayer? createWebAudioPlayer(String src) => null;
