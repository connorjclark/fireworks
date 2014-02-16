part of particles;

abstract class ExplosionMixin {
  List<Particle> explode(ParticlePool pool, num x, num y);
}

class RingExplosion implements ExplosionMixin {
  final int numParticles = 25;
  final num radius = 100;
  final num speed = 400;
  final Particle mold;
  
  RingExplosion(this.mold);
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    final particles = new List.generate(numParticles, (i) {
      final direction = PI * 2 * i / numParticles;
      final cosValue = cos(direction);
      final sinValue = sin(direction);
      final particle = pool.createFrom(mold);
      particle
          ..x = x 
          ..y = y
          ..xVel = speed * cosValue
          ..yVel = speed * sinValue;
      return particle;
    });
    return particles;
  }
}