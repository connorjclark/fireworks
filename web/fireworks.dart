import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

void main() {
  final stage = new Stage(html.querySelector("#stage"), color: Color.Transparent);
  stage.scaleMode = StageScaleMode.NO_SCALE;
  stage.align = StageAlign.TOP_LEFT;
  new RenderLoop().addStage(stage);
  
  final shape = new Shape();
  shape.graphics..circle(stage.stageWidth / 2, stage.stageHeight / 2, 300)..fillColor(Color.Blue);
  stage.addChild(shape);
}