part of particles;

abstract class TrailMixin {
  Particle createTrailParticle(ParticlePool pool, double dt, num x, num y);
}

class DefaultTrail implements TrailMixin {
  final num frequency;
  num timeLeftUntilNext = 0;
  final int color;
  
  DefaultTrail({this.color, this.frequency});
  
  Particle createTrailParticle(ParticlePool pool, double dt, num x, num y) {
    if (timeLeftUntilNext <= 0) {
      timeLeftUntilNext = frequency;
      return pool.create(x: x, y: y, life: 0.5, xVel: range(-10, 10), yVel: range(0, 50), color: rand.nextBool() ? Color.White: color, flickerRate: range(0, 0.1));
    } else {
      timeLeftUntilNext -= dt;
      return null;
    }
  }
}