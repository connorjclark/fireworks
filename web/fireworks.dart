import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
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
      doExploding();
    }
  });
}

void doExploding() {
  final xspeed = range(-100, 100);
  final yspeed = -range(200, 400);
  final x = range(stage.stageWidth/3, stage.stageWidth/3*2);
  final y = stage.stageHeight;
  final color = range(0, 0xffffff).toInt() + 0xff000000;
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
          
  if (rand.nextBool()) {
    final squarePoints = [new Point(-explosionSize/2, explosionSize/2), new Point(-explosionSize/2, -explosionSize/2),
                          new Point(explosionSize/2, -explosionSize/2), new Point(explosionSize/2, explosionSize/2)];
    final squareExplosion = new ShapeExplosion(shape: squarePoints, numParticles: numParticles, mold: mold);
    particle.explosionMixin = squareExplosion;
  } else {
    particle.explosionMixin = new RingExplosion(mold: mold, radius: explosionSize, numParticles: numParticles);
  }
  
  particle.trailMixin = new DefaultTrail(color: color, frequency: 0.005);
  
  display.add(particle);
}