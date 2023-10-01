import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:em_touch/data/constants/globals.dart';

final JoystickComponent joystick = JoystickComponent(
  knob: CircleComponent(
    radius: Globals.isTablet ? 30 : 15,
    paint: BasicPalette.brown.withAlpha(200).paint(),
  ),
  background: CircleComponent(
    radius: Globals.isTablet ? 100 : 60,
    paint: BasicPalette.lightGray.withAlpha(100).paint(),
  ),
  margin: const EdgeInsets.only(right: 40, bottom: 40),
);
