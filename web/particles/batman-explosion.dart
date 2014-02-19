//see http://www.calculushumor.com/3/post/2012/11/the-batman-curve.html

part of particles;

class BatmanExplosion extends ParametricExplosion {
  
  factory BatmanExplosion({num size, Particle mold, Interval numParticlesI, Interval thetaOffsetI}) {
    //bottom sides
    num g(num x) {
      return -3 * sqrt(1 - pow(x / 7, 2));
    }
    
    //bottom curves
    num h(num x) {
      return (x / 2).abs() - 0.0913722 * x * x - 3 + sqrt(1 - pow((x.abs() - 2).abs() - 1, 2));
    }
    
    //top dips
    num j(num x) {
      return 2.71052 + 1.5 - x.abs() / 2 - 1.35526 * sqrt(4 - pow(x.abs() - 1, 2)) + 0.9;
    }
    
    //top sides
    num f(num x) {
      return 2 * sqrt(1 - pow(x / 7, 2)) * (1 + (x.abs() - 3).abs() / (x.abs() - 3));
    }
    
    //top ears
    num e(num x) {
      return (5 + 0.97 * ((x - 0.5).abs() + (x + 0.5).abs() - 3 * ((x - 0.75).abs() + (x + 0.75).abs()))) * (1 + (1 - x.abs()).abs() / (1 - x.abs()));
    }
    
    //ensures that the slopes of the ears are emphasized
    final amount = 0.2;//amount to redirect to slopes of ears
    num tTransform(num t) {
      if (t <= 1 - amount) {
        return t / (1 - amount);
      } else {
        t = (1 - t) / amount;
        return 0.21 + ((t * 2) % 1) / 35 + (t >= 0.5 ? 1/20 : 0);
      }
    }
    
    num tToX(num t) {
      if (t > 0.5) return ((t - 0.5) / 0.5) * 14 - 14 / 2;
      return (t / 0.5) * 14 - 14 / 2;
    }
    
    num xt(num _t) {
      final t = tTransform(_t);
      return size * tToX(t) / 14;
    }
    
    num yt(num _t) {
      final t = tTransform(_t);
      final x = tToX(t);
      
      num y;
      
      if (t > 0.5) {
        //bottom half
        if (x >= 4 || x <= -4) y = g(x);
        else y = h(x);
      } else {
        //top half
        if ((x >= -3 && x <= -1) || (x >= 1 && x <= 3)) y = j(x);
        else if (x >= 3.5 || x <= -3.5) y = f(x);
        else y = e(x);
      } 
      
      return -size * y / 14;
    }
    
    return new BatmanExplosion._private(xt: xt, yt: yt, mold: mold, numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI);
  }
  
  BatmanExplosion._private({num xt(num t), num yt(num t), Particle mold, Interval numParticlesI, Interval thetaOffsetI}) :
    super(xt: xt, yt: yt, mold: mold, numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI);
}