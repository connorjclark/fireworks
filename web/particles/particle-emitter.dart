part of particles;

class ParticleEmitter {
  final Interval sizeI, gravityI, dragI, colorI, fadeI, lifeI;
  final TrailMixin? trailMixin;
  final ExplosionMixin? explosionMixin;
  final Function? explosionMixinClosure;

  ParticleEmitter(
      {required this.sizeI,
      required this.gravityI,
      required this.dragI,
      required this.colorI,
      required this.fadeI,
      required this.lifeI,
      this.trailMixin,
      this.explosionMixin,
      this.explosionMixinClosure}) {}

  Particle create(ParticlePool pool, num x, num y) {
    return pool.create(
        x: x,
        y: y,
        size: sizeI.next(),
        color: colorI.next(),
        numRings: 4,
        growth: 1,
        drag: dragI.next(),
        fade: fadeI.next(),
        life: lifeI.next(),
        gravity: gravityI.next(),
        trailMixin: trailMixin,
        explosionMixin: explosionMixinClosure != null
            ? explosionMixinClosure!()
            : explosionMixin);
  }
}
