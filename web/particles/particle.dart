part of particles;

class Particle extends Sprite {
  //ARGB color value
  int color = 0;

  //number of rings. rings create a neat visual effect when
  //the particle fades out. see draw()
  int numRings = 0;

  //how many seconds the particle lasts before it begins to decay
  num life = 0;

  //multiplier. after 1 second, the size of the particle
  //is roughly equal to growth*(size 1 second ago)
  num growth = 0;

  //multiplier. after 1 second, the speed of the particle
  //is roughly equal to drag*(speed 1 second ago)
  num drag = 0;

  //rate of change of the alpha value. alpha -= fade * dt
  num fade = 0;

  //how often in seconds the particle flickers
  num flickerRate = 0;
  num _timeLeftUntilNextFlicker = 0;

  //velocity is measured in terms pixels/second
  num xVel = 0, yVel = 0;

  num gravity = 0;

  bool isDecaying = false;

  ExplosionMixin? explosionMixin;

  TrailMixin? trailMixin;

  Particle._private();

  void init(
      {required num x,
      required num y,
      required num size,
      required int color,
      required int numRings,
      required num life,
      required num growth,
      required num drag,
      required num xVel,
      required num yVel,
      required num fade,
      required num gravity,
      required num flickerRate,
      ExplosionMixin? explosionMixin,
      TrailMixin? trailMixin,
      void onStartDeath(Particle p)?,
      void duringDeath(Particle p, double dt)?}) {
    this
      ..visible = true
      ..isDecaying = false
      ..onStartDeath(onStartDeath)
      ..duringDeath(duringDeath)
      ..explosionMixin = null
      ..trailMixin = null
      ..scaleX = scaleY = size
      ..alpha = 1
      ..x = x
      ..y = y
      ..color = color
      ..numRings = numRings
      ..life = life
      ..growth = growth
      ..drag = drag
      ..xVel = xVel
      ..yVel = yVel
      ..fade = fade
      ..gravity = gravity
      ..flickerRate = _timeLeftUntilNextFlicker = flickerRate
      ..trailMixin = trailMixin
      ..explosionMixin = explosionMixin;
    draw();
  }

  void update(num dt) {
    if ((life -= dt) <= 0) {
      if (isDecaying) {
        _duringDeath(this, dt);
      } else {
        isDecaying = true;
        _onStartDeath(this);
      }
    }

    if (flickerRate != 0 && (_timeLeftUntilNextFlicker -= dt) <= 0) {
      _timeLeftUntilNextFlicker = flickerRate;
      visible = !visible;
    }

    final drag_mult = pow(drag, dt);
    final growth_mult = pow(growth, dt);

    xVel *= drag_mult;
    yVel *= drag_mult;
    scaleX *= growth_mult;
    scaleY *= growth_mult;

    yVel += gravity * dt;
    x += xVel * dt;
    y += yVel * dt;
    alpha -= fade * dt;
  }

  var _onStartDeath;
  void onStartDeath(void f(Particle p)?) {
    _onStartDeath = f;
  }

  var _duringDeath;
  void duringDeath(void f(Particle p, double dt)?) {
    _duringDeath = f;
  }

  bool stillAlive() => alpha != 0;

  void draw() {
    graphics..clear();

    for (int i = 0; i < numRings; i++) {
      graphics
        ..circle(0, 0, (numRings - i) / numRings)
        ..fillColor(color);
    }
  }
}
