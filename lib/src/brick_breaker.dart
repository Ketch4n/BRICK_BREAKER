import 'dart:async';
import 'dart:math' as math;

import 'package:brick_breaker/src/custom/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  final BuildContext context;
  BrickBreaker(this.context)
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  late String playerName = '';
  final ValueNotifier<int> score = ValueNotifier(0);
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;

  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    overlays.clear(); // Clear overlays to avoid duplicates
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
        break;
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
        break;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(PlayArea());
    playState = PlayState.welcome;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _selectPlayer(context);
    });
  }

  void startGame() async {
    if (playState == PlayState.playing) return;

    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());

    playState = PlayState.playing;
    score.value = 0;

    world.add(Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: size / 2,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
            .normalized()
          ..scale(height / 4)));

    world.add(Bat(
        size: Vector2(200, 100),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(width / 2, height * 0.95)));

    world.addAll([
      for (var i = 0; i < brickColors.length; i++)
        for (var j = 1; j <= 5; j++)
          Brick(
            position: Vector2(
              (i + 0.5) * brickWidth + (i + 1) * brickGutter,
              (j + 2.0) * brickHeight + j * brickGutter,
            ),
            color: brickColors[i],
          ),
    ]);
  }

  Future<void> _selectPlayer(BuildContext context) async {
    playerName = await _getPlayerName(context);
    if (playerName.isEmpty) {
      const status = "Warning";
      const title = "Player name Empty!";
      const message = "please enter or select from existing players";
      // Player did not select a name, show prompt again
      await showAlertDialog(context, title, message, status);
      await _selectPlayer(context);
    }
  }

  Future<String> _getPlayerName(BuildContext context) async {
    String tempName = '';
    return await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Enter your name or select an existing account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      tempName = value;
                    },
                    decoration: InputDecoration(hintText: 'Player name'),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<List<String>>(
                    future: _fetchPlayerNames(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No existing accounts.');
                      } else {
                        return DropdownButton<String>(
                          hint: Text('Select existing account'),
                          onChanged: (value) {
                            Navigator.of(context).pop(value);
                          },
                          items: snapshot.data!
                              .map((name) => DropdownMenuItem<String>(
                                    value: name,
                                    child: Text(name),
                                  ))
                              .toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(tempName);
                  },
                ),
              ],
            );
          },
        ) ??
        '';
  }

  Future<List<String>> _fetchPlayerNames() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('scores').get();

    return snapshot.docs.map((doc) => doc['playerName'] as String).toList();
  }

  Future<void> saveScore() async {
    final existingScoreDoc = await FirebaseFirestore.instance
        .collection('scores')
        .where('playerName', isEqualTo: playerName)
        .get();

    if (existingScoreDoc.docs.isNotEmpty) {
      final doc = existingScoreDoc.docs.first;
      final existingScore = doc['score'] as int;

      if (score.value > existingScore) {
        const status = "Success";
        const title = "New High Score";
        const message = "you beat your previous record";
        await doc.reference.update({
          'score': score.value,
          'timestamp': Timestamp.now(),
        });
        showAlertDialog(context, title, message, status);
      }
    } else {
      const status = "Success";
      const title = "New Score";
      final message = "Player '$playerName' added to the leaderboard";
      await FirebaseFirestore.instance.collection('scores').add({
        'playerName': playerName,
        'score': score.value,
        'timestamp': Timestamp.now(),
      });
      showAlertDialog(context, title, message, status);
    }
  }

  Future<void> onGameOver() async {
    playState = PlayState.gameOver;
    await saveScore();
  }

  Future<void> onGameWon() async {
    playState = PlayState.won;
    await saveScore();
  }

  void checkForWin() {
    if (world.children.query<Brick>().isEmpty) {
      onGameWon();
    }
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
        break;
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
        break;
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        startGame();
        break;
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
