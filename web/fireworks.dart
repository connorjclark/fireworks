import 'dart:html' as html;
import 'package:stagexl/stagexl.dart' hide Shape;
import 'particles/particles.dart';
import 'dart:math' hide Point;

final stage = new Stage(html.querySelector("#stage"), color: Color.Transparent);
final display = new ParticleDisplay();

void main() {
  stage.scaleMode = StageScaleMode.NO_SCALE;
  stage.align = StageAlign.TOP_LEFT;
  
  var resourceManager = new ResourceManager()
      ..addBitmapData('moon', 'images/moon.png');

  resourceManager.load().then((result) {
    var moon = new Bitmap(resourceManager.getBitmapData('moon'));
    moon.alpha = 0.6;
    
    stage.addChild(moon);
    stage.addChild(display);
    
    new RenderLoop().addStage(stage);
    start();
  });
}

void start() {
  final fireworkInterval = 1;
  var constantLaunching = true;
  var timeElapsed = 0.0;
  stage.onEnterFrame.listen((event) {
    if (timeElapsed > 1) timeElapsed = 0;
    timeElapsed += event.passedTime;
    if (timeElapsed >= fireworkInterval && constantLaunching) {
      timeElapsed -= fireworkInterval;
      final x = range(stage.stageWidth / 5, stage.stageWidth / 5 * 4);
      final y = range(stage.stageHeight / 3, stage.stageHeight / 3 * 2);
      createFirework(new Point(x, y));
    }
  });
    
  html.querySelector("body").onClick.listen((event) {
    createFirework(new Point(event.client.x, event.client.y));
  });
  
  html.querySelector("body").onKeyUp.listen((event) {
    if (event.keyCode == html.KeyCode.SPACE) constantLaunching = !constantLaunching;
  });
}

void createFirework(Point destination) {
  final drag = 1;
  final gravity = 10;
  final speed = range(400, 700);
  
  final origin = new Point(range(stage.stageWidth / 3, stage.stageWidth / 3 * 2), stage.stageHeight);
  final positionDelta = destination.subtract(origin);
  final theta = atan2(positionDelta.y, positionDelta.x);
  final distanceToTravel = positionDelta.length;
  
  final travelTime = distanceToTravel / speed;
  final velocity = new Point(speed * cos(theta), speed * sin(theta));
    
  final color = randomLightColor();
  final numParticles = range(10, 30).toInt();
  final explosionSize = range(100, 200);
  final mold = display.pool.create(
    x: 600, y: 800, size: range(2, 3), color: color, numRings: 4, life: 1,
    growth: 0.6, drag: 0.1, xVel: 0, yVel: 0, fade: 0.95, gravity: 300.0, 
    trailMixin: new DefaultTrail(color: color, frequency: 0.1)
  );
  
  final particle = display.pool.create(
    x: origin.x, y: origin.y, size: range(2, 4), color: color, numRings: 4, life: travelTime, 
    growth: 1, drag: drag, xVel: velocity.x, yVel: velocity.y, fade: 0, gravity: gravity, 
    onStartDeath: (Particle p) => p.fade = double.MAX_FINITE
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