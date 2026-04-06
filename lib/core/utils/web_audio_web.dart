// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'web_audio_interface.dart';

class WebAudioPlayerImpl implements WebAudioPlayer {
  final html.AudioElement _audio;

  WebAudioPlayerImpl(String src) : _audio = html.AudioElement()..src = src;

  @override
  void play() => _audio.play();
  
  @override
  void stop() => _audio.pause();

  @override
  void dispose() => _audio.remove();

  @override
  set currentTime(double value) => _audio.currentTime = value;

  @override
  set volume(double value) => _audio.volume = value;
}

WebAudioPlayer? createWebAudioPlayer(String src) => WebAudioPlayerImpl(src);
