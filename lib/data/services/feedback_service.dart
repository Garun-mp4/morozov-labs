import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum FeedbackEvent { tap, correct, wrong, complete, perfect, selection }

class FeedbackService {
  FeedbackService() : _player = AudioPlayer();

  final AudioPlayer _player;

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  void configure({required bool sound, required bool haptics}) {
    soundEnabled = sound;
    hapticsEnabled = haptics;
  }

  Future<void> play(FeedbackEvent event) async {
    final futures = <Future<void>>[];

    if (soundEnabled && event != FeedbackEvent.selection) {
      futures.add(_playSound(event));
    }

    if (hapticsEnabled) {
      futures.add(_playHaptic(event));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> _playSound(FeedbackEvent event) async {
    final asset = switch (event) {
      FeedbackEvent.tap => 'audio/tap.wav',
      FeedbackEvent.correct => 'audio/correct.wav',
      FeedbackEvent.wrong => 'audio/wrong.wav',
      FeedbackEvent.complete => 'audio/complete.wav',
      FeedbackEvent.perfect => 'audio/perfect.wav',
      FeedbackEvent.selection => 'audio/tap.wav',
    };

    try {
      await _player.stop();
      if (Platform.isAndroid) {
        await _player.setPlayerMode(PlayerMode.lowLatency);
      }
      await _player.play(AssetSource(asset), volume: 0.72);
    } catch (_) {
      // Audio feedback is non-critical and must never block the training flow.
    }
  }

  Future<void> _playHaptic(FeedbackEvent event) async {
    try {
      switch (event) {
        case FeedbackEvent.selection:
          await HapticFeedback.selectionClick();
          break;
        case FeedbackEvent.tap:
          await HapticFeedback.lightImpact();
          break;
        case FeedbackEvent.correct:
          await HapticFeedback.lightImpact();
          break;
        case FeedbackEvent.wrong:
          await HapticFeedback.errorNotification();
          break;
        case FeedbackEvent.complete:
        case FeedbackEvent.perfect:
          await HapticFeedback.successNotification();
          break;
      }
    } catch (_) {
      // Haptics can be unavailable on desktop and older Android devices.
    }
  }

  Future<void> dispose() => _player.dispose();
}
