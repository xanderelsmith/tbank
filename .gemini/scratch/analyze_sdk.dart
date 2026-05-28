import 'package:toronet/toronet.dart';
import 'dart:mirrors';

void main() {
  final sdkMirror = reflectClass(ToronetSDK);
  print('--- ToronetSDK Constructors ---');
  sdkMirror.declarations.forEach((key, value) {
    if (value is MethodMirror && value.isConstructor) {
      print('${MirrorSystem.getName(key)}: ${value.parameters.map((p) => '${p.type.reflectedType} ${MirrorSystem.getName(p.simpleName)}').toList()}');
    }
  });

  final optionsMirror = reflectClass(SDKOptions);
  print('--- SDKOptions Properties ---');
  optionsMirror.declarations.forEach((key, value) {
    if (value is VariableMirror) {
      print('${MirrorSystem.getName(key)}: ${value.type.reflectedType}');
    }
  });
}
