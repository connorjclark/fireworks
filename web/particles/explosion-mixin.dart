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
  final List<Point> shape;
  List<num> lengths;
  List<Point> directions;
  num perimeter;
  
  ShapeExplosion({this.mold, this.numParticles, this.shape}) {
    lengths = new List();
    directions = new List();
    perimeter = 0;
    
    for (var i = 0; i < shape.length; i++) {
      final current = shape[i];
      final next = shape[(i + 1) % shape.length];
      final len = current.distanceTo(next);
      final dir = new Point(next.x - current.x, next.y - current.y);
      dir.normalize(1);
      
      perimeter += len;
      lengths.add(len);
      directions.add(dir);
    }
  }
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    var runningLength = 0;
    var currentIndex = 0;
    final thetaOffset = range(0, PI2);
    
    return new List.generate(numParticles, (i) {
      
      while ((lengths[currentIndex] + runningLength) / perimeter < i / numParticles ) {
        runningLength += lengths[currentIndex];
        currentIndex++;
      }
            
      final currentLength = lengths[currentIndex];
      final currentPercentage = (runningLength) / perimeter;
      final nextPercentage = (currentLength + runningLength) / perimeter;
      final interpolated = (i / numParticles - currentPercentage) / (nextPercentage - currentPercentage);
      
      final dir = directions[currentIndex];
      final point = new Point(shape[currentIndex].x + dir.x * currentLength * interpolated, shape[currentIndex].y + dir.y * currentLength * interpolated);
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