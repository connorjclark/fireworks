part of particles;

class ParticleDisplay extends Sprite {
  final ParticlePool pool = new ParticlePool(100);
  final List<Particle> activeParticles = new List();
  
  ParticleDisplay() {
    onEnterFrame.listen((event) => _update(event.passedTime));
    this.filters.add(new BlurFilter(8, 8));
  }
  
  void _update(num dt) {
    final newParticles = [];
    activeParticles.removeWhere((particle) {
      particle.update(dt);
      
      if (particle.trailMixin != null) {
        final trail = particle.trailMixin.createTrailParticle(pool, dt, particle.x, particle.y);
        if (trail != null) newParticles.add(trail);
      }
      
      final stillAlive = particle.stillAlive();
      if (!stillAlive) {
        if (particle.explosionMixin != null) {
          particle.explosionMixin.explode(pool, particle.x, particle.y).forEach((newParticle) {
            newParticles.add(newParticle);
          });
        }
        removeChild(particle); //O(n)...
        pool.returnToPool(particle);
      }
      return !stillAlive;
    });
    if (newParticles.isNotEmpty) addAll(newParticles);
    if (activeParticles.length < 100) {
      doExploding();
    }
  }
  
  void doExploding() {
    final xspeed = range(-100, 100);
    final yspeed = -range(100, 400);
    final x = range(stage.stageWidth/3, stage.stageWidth/3*2);
    final y = stage.stageHeight;
    final color = range(0, 0xffffff).toInt() + 0xff000000;
    
    final p = pool.create(x: x, y: y, size: range(2, 4), color: color, numRings: 4, life: range(1, 5), growth: 1, drag: 1, xVel: xspeed, yVel: yspeed, fade: 0, gravity: 50.0);
    
    p.explosionMixin = new RingExplosion(
      pool.create(x: 600, y: 800, size: range(3, 5), color: color, numRings: 4, life: 1,
                  growth: 0.6, drag: 0.1, xVel: 0, yVel: 0, fade: 0.95, gravity: 300.0));
    
    p.trailMixin = new DefaultTrail(color);
    
    add(p);
  }
  
  void add(Particle particles) {
    addChild(particles);
    activeParticles.add(particles);
  }
  
  void addAll(List<Particle> particles) {
   activeParticles.addAll(particles);
   activeParticles.forEach((_) => _.addTo(this));
  }
}