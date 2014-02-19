part of particles;

abstract class ExplosionMixin {
  final Particle mold;
  final int numParticles;
  final Interval thetaOffset;
  
  ExplosionMixin({this.mold, this.numParticles, this.thetaOffset});

  List<Particle> explode(ParticlePool pool, num x, num y);

  /*
   * dist = integral of initialSpeed * drag^t * dt from 0 to 1
   *      = (drag - 1) * initialSpeed / ln(drag)
   * solve for necessary initial speed given following constraints:
   * (1) particle's speed is multiplied by a drag value w/ respect to time
   * (2) given the particle lives long enough, it will stop moving at
   *     a distance of 'dist' from the center
   */
  num _calculateSpeed(num dist) => dist * log(mold.drag) / (mold.drag - 1);
}

class RingExplosion extends ExplosionMixin {
  final num radius;
  
  RingExplosion({this.radius, Particle mold, int numParticles, Interval thetaOffset}) :
    super(mold: mold, numParticles: numParticles, thetaOffset: thetaOffset);
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    final speed = _calculateSpeed(radius);
    final offset = thetaOffset.next();
    return new List.generate(numParticles, (i) {
      final theta = PI2 * i / numParticles + offset;
      
      final particle = pool.createFrom(mold);
      particle
          ..x = x 
          ..y = y
          ..xVel = speed * cos(theta)
          ..yVel = speed * sin(theta);
      return particle;
    });
  }
}

class ShapeExplosion extends ExplosionMixin {
  final Shape shape;
  
  ShapeExplosion({this.shape, Particle mold, int numParticles, Interval thetaOffset}) :
    super(mold: mold, numParticles: numParticles, thetaOffset: thetaOffset);
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    var runningLength = 0;
    var currentIndex = 0;
    final offset = thetaOffset.next();
    
    return new List.generate(numParticles, (i) {
      while ((shape.lengths[currentIndex] + runningLength) / shape.perimeter < i / numParticles ) {
        runningLength += shape.lengths[currentIndex];
        currentIndex++;
      }
            
      final currentLength = shape.lengths[currentIndex];
      final currentPercentage = (runningLength) / shape.perimeter;
      final nextPercentage = (currentLength + runningLength) / shape.perimeter;
      final interpolated = (i / numParticles - currentPercentage) / (nextPercentage - currentPercentage);
      
      final dir = shape.directions[currentIndex];
      final point = new Point(shape.vertices[currentIndex].x + dir.x * currentLength * interpolated, shape.vertices[currentIndex].y + dir.y * currentLength * interpolated);
      final distance = point.length;
      final theta = atan2(point.y, point.x) + offset;
      final speed = _calculateSpeed(distance);
      
      final particle = pool.createFrom(mold);
      particle
          ..x = x 
          ..y = y
          ..xVel = speed * cos(theta)
          ..yVel = speed * sin(theta);
      return particle;
    });
  }
}

class ParametricExplosion extends ExplosionMixin {
  final xt, yt;
  
  ParametricExplosion({num this.xt(num t), num this.yt(num t), Particle mold, int numParticles, Interval thetaOffset}) :
    super(mold: mold, numParticles: numParticles, thetaOffset: thetaOffset);
  
  ParametricExplosion.ellipse({num xRadius, num yRadius, Particle mold, int numParticles, Interval thetaOffset}) :
    super(mold: mold, numParticles: numParticles, thetaOffset: thetaOffset),
    xt = ((t) => xRadius * cos(t * PI2)),
    yt = ((t) => yRadius * sin(t* PI2));
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    var runningLength = 0;
    var currentIndex = 0;
    final offset = thetaOffset.next();
    
    return new List.generate(numParticles, (i) {
      final t = i / numParticles;
      final point = new Point(xt(t), yt(t));
      final distance = point.length;
      final theta = atan2(point.y, point.x) + offset;
      final speed = _calculateSpeed(distance);
      
      final particle = pool.createFrom(mold);
      particle
          ..x = x 
          ..y = y
          ..xVel = speed * cos(theta)
          ..yVel = speed * sin(theta);
      return particle;
    });
  }
}