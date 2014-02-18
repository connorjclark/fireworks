import 'dart:html' as html;
import 'package:stagexl/stagexl.dart' hide Shape;
import 'particles/particles.dart';

final stage = new Stage(html.querySelector("#stage"), color: Color.Transparent);
final display = new ParticleDisplay();

void main() {
  stage.scaleMode = StageScaleMode.NO_SCALE;
  stage.align = StageAlign.TOP_LEFT;
  stage.addChild(display);
  new RenderLoop().addStage(stage);
  
  final fireworkInterval = 1;
  num timeElapsed = 0;
  stage.onEnterFrame.listen((event) {
    timeElapsed += event.passedTime;
    if (timeElapsed >= fireworkInterval) {
      timeElapsed -= fireworkInterval;
      createFirework();
    }
  });
}

void createFirework() {
  final xspeed = range(-100, 100);
  final yspeed = -range(200, 500);
  final x = range(stage.stageWidth/3, stage.stageWidth/3*2);
  final y = stage.stageHeight;
  final color = randomLightColor();
  final numParticles = range(10, 30).toInt();
  final explosionSize = range(100, 200);
  final mold = display.pool.create(
    x: 600, y: 800, size: range(2, 3), color: color, numRings: 4, life: 1,
    growth: 0.6, drag: 0.1, xVel: 0, yVel: 0, fade: 0.95, gravity: 300.0, 
    trailMixin: new DefaultTrail(color: color, frequency: 0.1)
  );
  
  final particle = display.pool.create(
    x: x, y: y, size: range(2, 4), color: color, numRings: 4, life: range(1, 3), 
    growth: 1, drag: 1, xVel: xspeed, yVel: yspeed, fade: 0, gravity: 100.0
  );
  
  final chance = rand.nextDouble();
  if (chance < .1) {
    final squareVertices = [new Point(-explosionSize/2, explosionSize/2), new Point(-explosionSize/2, -explosionSize/2),
                            new Point(explosionSize/2, -explosionSize/2), new Point(explosionSize/2, explosionSize/2)];
    final squareExplosion = new ShapeExplosion(shape: new Shape(squareVertices), numParticles: numParticles, mold: mold);
    particle.explosionMixin = squareExplosion;
  } else if (chance < .5) {
    particle.explosionMixin = new RingExplosion(mold: mold, radius: explosionSize, numParticles: numParticles);
  } else {
    final p = range(5, 10).toInt();
    final q = range(2, 3).toInt();
    particle.explosionMixin = new ShapeExplosion(shape: new Shape.star(p, q, explosionSize), numParticles: (numParticles * 1.5).toInt(), mold: mold);
  }
    
  particle.trailMixin = new DefaultTrail(color: color, frequency: 0.005);
  
  display.add(particle);
}

//generates a random color of a light pallete by averaging a random color with white
int randomLightColor() => 0xff000000 | (range(0, 255) + 255) ~/ 2 | (range(0, 255) + 255) ~/ 2 << 8 | (range(0, 255) + 255) ~/ 2 << 16;