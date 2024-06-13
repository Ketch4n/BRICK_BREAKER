import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart';
import 'play_area.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()
            ..color = const Color(0xff1e6091)
            ..style = PaintingStyle.fill,
          children: [CircleHitbox()],
        );

  final Vector2 velocity;
  final double difficultyModifier;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayArea) {
      _handlePlayAreaCollision(intersectionPoints);
    } else if (other is Bat) {
      _handleBatCollision(other);
    } else if (other is Brick) {
      _handleBrickCollision(other);
    }
  }

  void _handlePlayAreaCollision(Set<Vector2> intersectionPoints) {
    if (intersectionPoints.first.y <= 0) {
      velocity.y = -velocity.y;
    } else if (intersectionPoints.first.x <= 0 ||
        intersectionPoints.first.x >= game.size.x) {
      velocity.x = -velocity.x;
    } else if (intersectionPoints.first.y >= game.size.y) {
      add(RemoveEffect(
        delay: 0.35,
        onComplete: () {
          game.onGameOver();
        },
      ));
    }
  }

  void _handleBatCollision(Bat bat) {
    velocity.y = -velocity.y;
    velocity.x +=
        (position.x - bat.position.x) / bat.size.x * game.size.x * 0.3;
  }

  void _handleBrickCollision(Brick brick) {
    if (position.y < brick.position.y - brick.size.y / 2 ||
        position.y > brick.position.y + brick.size.y / 2) {
      velocity.y = -velocity.y;
    } else {
      velocity.x = -velocity.x;
    }
    velocity.setFrom(velocity * difficultyModifier);
    brick.removeFromParent();
    game.score.value += 0;
    game.checkForWin();
  }
}
