import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'particles/particles.dart';

void main() {
  final stage = new Stage(html.querySelector("#stage"), color: Color.Transparent);
  stage.scaleMode = StageScaleMode.NO_SCALE;
  stage.align = StageAlign.TOP_LEFT;
  new RenderLoop().addStage(stage);
  
  final particleDisplay = new ParticleDisplay();
  stage.addChild(particleDisplay);
  
}