part of particles;

abstract class ExplosionMixin {
  List<Particle> explode(ParticlePool pool, num x, num y);
}

class RingExplosion implements ExplosionMixin {
  final int numParticles;
  final num radius;
  final Particle mold;
  
  RingExplosion({this.mold, this.numParticles, this.radius});
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    //radius = integral of initialSpeed * drag^t * dt from 0 to 1
    //       = (drag - 1) * initialSpeed / ln(drag)
    //solve for necessary initial speed given following constraints:
    // (1) particle's speed is multiplied by a drag value w/ respect to time
    // (2) given the particle lives long enough, it will stop moving at
    //     a distance of 'radius' from the center
    final speed = radius * log(mold.drag) / (mold.drag - 1);
    
    final thetaOffset = range(0, PI2);
    
    return new List.generate(numParticles, (i) {
      final theta = PI2 * i / numParticles + thetaOffset;
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

class ShapeExplosion implements ExplosionMixin {
  final Particle mold;
  final int numParticles;
  final Shape shape;
  
  ShapeExplosion({this.mold, this.numParticles, this.shape});
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    var runningLength = 0;
    var currentIndex = 0;
    final thetaOffset = range(0, PI2);
    
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
      
      final speed = distance * log(mold.drag) / (mold.drag - 1);
      
      final theta = atan2(point.y, point.x) + thetaOffset;
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

class ParametricExplosion implements ExplosionMixin {
  final xt, yt;
  final Particle mold;
  final int numParticles;
  
  ParametricExplosion({num this.xt(num t), num this.yt(num t), this.mold, this.numParticles});
  
  ParametricExplosion.ellipse({num xRadius, num yRadius, this.mold, this.numParticles}) :
    xt = ((t) => xRadius * cos(t * PI2)),
    yt = ((t) => yRadius * sin(t* PI2));
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    var runningLength = 0;
    var currentIndex = 0;
    final thetaOffset = range(0, PI2);
    
    return new List.generate(numParticles, (i) {
      final t = i / numParticles;
      final point = new Point(xt(t), yt(t));
      final distance = point.length;
      
      final speed = distance * log(mold.drag) / (mold.drag - 1);
      
      final theta = atan2(point.y, point.x) + thetaOffset;
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