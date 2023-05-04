// @dart=2.9

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart' hide Shape;
import 'particles/particles.dart';
import 'dart:math';

final stage = new Stage(html.querySelector("#stage"));
final display = new ParticleDisplay();

void main() {
  stage.scaleMode = StageScaleMode.NO_SCALE;
  stage.align = StageAlign.TOP_LEFT;
  stage.backgroundColor = Color.Transparent;
  
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
  initializeFireworksSelection();
  final fireworkInterval = 1.5;
  final xI = new Interval.normal(mean: stage.stageWidth / 2, sd: 200);
  var constantLaunching = true;
  var timeElapsed = 0.0;
  num fpsAverage = null;
  
  stage.onEnterFrame.listen((event) {
    if (timeElapsed > 5) timeElapsed = 0;
    timeElapsed += event.passedTime;
    if (timeElapsed >= fireworkInterval && constantLaunching) {
      timeElapsed -= fireworkInterval;
      final x = xI.next();
      final y = range(stage.stageHeight / 3, stage.stageHeight / 3 * 2);
      createFireworks(new Point(x, y));
    }
    
    if (fpsAverage == null) {
      fpsAverage = 1.00 / event.passedTime;
    } else {
      fpsAverage = 0.05 / event.passedTime + 0.95 * fpsAverage;
    }
    
    html.querySelector("#fps").text = "FPS: ${fpsAverage.round()} Particles:${display.numChildren}";
  });
    
  html.querySelector("body").onClick.listen((event) {
    createFireworks(new Point(event.client.x, event.client.y));
  });
  
  html.querySelector("body").onKeyUp.listen((event) {
    if (event.keyCode == html.KeyCode.SPACE) constantLaunching = !constantLaunching;
    if (event.keyCode == html.KeyCode.H) {
      var el = html.querySelector('#text-div');
      el.hidden = !el.hidden;
    }
  });
}

final List<ParticleEmitter> fireworksSelection = [];

void initializeFireworksSelection() {
  //define common components
  final sizeI = new Interval.normal(mean: 2.5, sd: 0.5, min: 1);
  final colorI = new Interval(randomLightColor);
  final dragI = new Interval.constant(1);
  final gravityI = new Interval.constant(10);
  final fadeI = new Interval.constant(0);
  final lifeI = new Interval.constant(1);
  final trailMixin = new DefaultTrail(colorI: colorI, frequency: 0.005);
  final PI2 = pi * 2;
  
  //common explosion components
  final explosionEmitter = new ParticleEmitter(
    sizeI: sizeI, colorI: colorI, dragI: new Interval.constant(0.1), fadeI: new Interval.constant(0.95),
    gravityI: new Interval.constant(100), lifeI: lifeI, trailMixin: new DefaultTrail(colorI: colorI, frequency: 0.1),
    explosionMixin: null
  );
  final thetaOffsetI = new Interval.uniform(-pi / 4, pi / 4);
  final thetaOffsetI_2 = new Interval.uniform(pi - pi / 4, pi + pi / 4);
  final numParticlesI = new Interval.normal(mean: 25, sd: 8, min: 5);
  final numParticlesI_2 = new Interval.normal(mean: 45, sd: 8, min: 20);
  final numParticlesI_3 = new Interval.normal(mean: 120, sd: 20, min: 80);
  final explosionSizeI = new Interval.normal(mean: 150, sd: 25, min: 20);
  
  //begin designing fireworks
  
  //a square explosion
  final squareVertices = [
    new Point(-0.5, 0.5), new Point(-0.5, -0.5),
    new Point(0.5, -0.5), new Point(0.5, 0.5)
  ];
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ShapeExplosion(
      shape: new Shape(squareVertices), emitter: explosionEmitter,
      numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
  
  //a circular explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new RingExplosion(
      emitter: explosionEmitter, numParticlesI: numParticlesI,
      thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
  
  //a star explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixinClosure: () {
      final p = range(5, 10).toInt();
      final q = range(2, 3).toInt();
      return new ShapeExplosion(
        shape: new Shape.star(p, q, 1), emitter: explosionEmitter, thetaOffsetI: thetaOffsetI,
        numParticlesI: numParticlesI_2, sizeI: explosionSizeI
      );
    } 
  ));
  
  //an elliptic explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixinClosure: () {
      return new ParametricExplosion.ellipse(
        xyRatio: rand.nextBool() ? range(0.6, 0.85) : 1 - range(0.6, 0.85), sizeI: explosionSizeI,
        numParticlesI: numParticlesI_2,
        emitter: explosionEmitter, thetaOffsetI: thetaOffsetI
      );
    }
  ));
  
  //a heart explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) => pow(sin(t * PI2), 3),
      yt: (t) => -(13 * cos(t * PI2) - 5 * cos(2 * t * PI2) - 2 * cos(3 * t * PI2) - cos(4 * t * PI2)) / 16,
      numParticlesI: numParticlesI_2, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
  
  //a batman explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new BatmanExplosion(
      sizeI: new Interval.normal(mean: 300, sd: 50, min: 150), emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, numParticlesI: new Interval.normal(mean: 60, sd: 10, min: 40)
    )
  ));
  
  //okay so now here are some explosions using some cool parametric equations
    
  //astroid
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) { final cost = cos(t * PI2); return cost * cost * cost; },
      yt: (t) { final sint = sin(t * PI2); return sint * sint * sint; },
      numParticlesI: numParticlesI_2, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
  
  //nephroid
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixinClosure: () {
      final a = range(0.25, 1.0);
      final b = a / 2;
      return new ParametricExplosion(
        xt: (t) => (a + b) * cos(t * PI2 * 2) - b * cos(t * PI2 * 2 * (a / b + 1)),
        yt: (t) => (a + b) * sin(t * PI2 * 2) - b * sin(t * PI2 * 2 * (a / b + 1)),
        numParticlesI: numParticlesI_2, emitter: explosionEmitter,
        thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
      );
    }
  ));
  
  //involute of a circle
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) { final T = t * PI2 * 2; return cos(T) + T * sin(T); },
      yt: (t) { final T = t * PI2 * 2; return sin(T) - T * cos(T); },
      numParticlesI: numParticlesI_2, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, sizeI: new Interval.normal(mean: 15, sd: 5, min: 5)
    )
  ));
  
  //triscuspoid
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) { final T = t * PI2; return cos(T) + cos(2 * T) / 2; },
      yt: (t) { final T = t * PI2; return sin(T) - sin(2 * T) / 2; },
      numParticlesI: numParticlesI_2, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));

  //cat
  final cat = new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) { final T = t * PI2; return (-(721*sin(T))/4+196/3*sin(2*T)-86/3*sin(3*T)-131/2*sin(4*T)+477/14*sin(5*T)+27*sin(6*T)-29/2*sin(7*T)+68/5*sin(8*T)+1/10*sin(9*T)+23/4*sin(10*T)-19/2*sin(12*T)-85/21*sin(13*T)+2/3*sin(14*T)+27/5*sin(15*T)+7/4*sin(16*T)+17/9*sin(17*T)-4*sin(18*T)-1/2*sin(19*T)+1/6*sin(20*T)+6/7*sin(21*T)-1/8*sin(22*T)+1/3*sin(23*T)+3/2*sin(24*T)+13/5*sin(25*T)+sin(26*T)-2*sin(27*T)+3/5*sin(28*T)-1/5*sin(29*T)+1/5*sin(30*T)+(2337*cos(T))/8-43/5*cos(2*T)+322/5*cos(3*T)-117/5*cos(4*T)-26/5*cos(5*T)-23/3*cos(6*T)+143/4*cos(7*T)-11/4*cos(8*T)-31/3*cos(9*T)-13/4*cos(10*T)-9/2*cos(11*T)+41/20*cos(12*T)+8*cos(13*T)+2/3*cos(14*T)+6*cos(15*T)+17/4*cos(16*T)-3/2*cos(17*T)-29/10*cos(18*T)+11/6*cos(19*T)+12/5*cos(20*T)+3/2*cos(21*T)+11/12*cos(22*T)-4/5*cos(23*T)+cos(24*T)+17/8*cos(25*T)-7/2*cos(26*T)-5/6*cos(27*T)-11/10*cos(28*T)+1/2*cos(29*T)-1/5*cos(30*T))/400; },
      yt: (t) { final T = t * PI2; return (-(637*sin(T))/2-188/5*sin(2*T)-11/7*sin(3*T)-12/5*sin(4*T)+11/3*sin(5*T)-37/4*sin(6*T)+8/3*sin(7*T)+65/6*sin(8*T)-32/5*sin(9*T)-41/4*sin(10*T)-38/3*sin(11*T)-47/8*sin(12*T)+5/4*sin(13*T)-41/7*sin(14*T)-7/3*sin(15*T)-13/7*sin(16*T)+17/4*sin(17*T)-9/4*sin(18*T)+8/9*sin(19*T)+3/5*sin(20*T)-2/5*sin(21*T)+4/3*sin(22*T)+1/3*sin(23*T)+3/5*sin(24*T)-3/5*sin(25*T)+6/5*sin(26*T)-1/5*sin(27*T)+10/9*sin(28*T)+1/3*sin(29*T)-3/4*sin(30*T)-(125*cos(T))/2-521/9*cos(2*T)-359/3*cos(3*T)+47/3*cos(4*T)-33/2*cos(5*T)-5/4*cos(6*T)+31/8*cos(7*T)+9/10*cos(8*T)-119/4*cos(9*T)-17/2*cos(10*T)+22/3*cos(11*T)+15/4*cos(12*T)-5/2*cos(13*T)+19/6*cos(14*T)+7/4*cos(15*T)+31/4*cos(16*T)-cos(17*T)+11/10*cos(18*T)-2/3*cos(19*T)+13/3*cos(20*T)-5/4*cos(21*T)+2/3*cos(22*T)+1/4*cos(23*T)+5/6*cos(24*T)+3/4*cos(26*T)-1/2*cos(27*T)-1/10*cos(28*T)-1/3*cos(29*T)-1/19*cos(30*T))/400; },
      numParticlesI: numParticlesI_3, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI_2, sizeI: explosionSizeI
    )
  );
  fireworksSelection.add(cat);

  Uri uri = new Uri.dataFromString(html.window.location.href);
  if (uri.queryParameters.containsKey('alfred')) {
    fireworksSelection.clear();
    fireworksSelection.add(cat);
  }
}

void createFireworks(Point destination) {
  final speed = range(400, 700);
  final origin = new Point(new Interval.normal(mean: stage.stageWidth / 2, sd: 100).next(), stage.stageHeight);
  final positionDelta = destination - origin;
  final theta = atan2(positionDelta.y, positionDelta.x);
  final distanceToTravel = positionDelta.magnitude;
  final travelTime = distanceToTravel / speed;
  final velocity = new Point(speed * cos(theta), speed * sin(theta));
  final Particle particle = fireworksSelection[rand.nextInt(fireworksSelection.length)].create(display.pool, origin.x, origin.y);
  particle
      ..xVel = velocity.x
      ..yVel = velocity.y
      ..life = travelTime;
  display.add(particle);
}

//generates a random color of a light pallete by averaging a random color with white
int randomLightColor() => 0xff000000 | (range(0, 255) + 255) ~/ 2 | (range(0, 255) + 255) ~/ 2 << 8 | (range(0, 255) + 255) ~/ 2 << 16;