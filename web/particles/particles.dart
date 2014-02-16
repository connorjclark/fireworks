library particles;

import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'particle.dart';
part 'emitter.dart';
part 'particle-display.dart';
part 'particle-pool.dart';
part 'explosion-mixin.dart';
part 'trail-mixin.dart';

final Random rand = new Random();
num range(num min, num max) => rand.nextDouble() * (max - min) + min;