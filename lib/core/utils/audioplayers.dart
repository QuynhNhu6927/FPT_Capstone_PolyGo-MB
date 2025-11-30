import 'package:audioplayers/audioplayers.dart';

class CallSoundManager {
  static final CallSoundManager _instance = CallSoundManager._internal();
  factory CallSoundManager() => _instance;

  CallSoundManager._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playRingTone() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('ring-tone.mp3'), volume: 1.0);
  }

  Future<void> stopRingTone() async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.release);
  }

  Future<void> playComingCall() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('call-request.mp3'), volume: 1.0);
  }

  Future<void> stopComingCall() async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.release);
  }

  Future<void> playEndCall() async {
    await _player.setReleaseMode(ReleaseMode.release);
    await _player.play(AssetSource('end-call.mp3'), volume: 1.0);
  }

  Future<void> playReactPost() async {
    await _player.setReleaseMode(ReleaseMode.release);
    await _player.play(AssetSource('pop.mp3'), volume: 1.0);
  }

}
