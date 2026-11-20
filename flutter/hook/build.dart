import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) return;
    final config = input.config.code;
    final slice = switch ((config.targetOS, config.targetArchitecture)) {
      (OS.android, Architecture.arm) => 'android-arm',
      (OS.android, Architecture.arm64) => 'android-arm64',
      (OS.android, Architecture.x64) => 'android-x64',
      (OS.iOS, Architecture.x64) when config.iOS.targetSdk == IOSSdk.iPhoneSimulator => 'ios-sim-x64',
      (OS.iOS, Architecture.arm64) => config.iOS.targetSdk == IOSSdk.iPhoneSimulator
          ? 'ios-sim-arm64' : 'ios-arm64',
      _ => throw UnsupportedError('Unsupported target for sample_rust_core_flutter: ${config.targetOS} ${config.targetArchitecture}'),
    };
    final suffix = config.targetOS == OS.iOS ? 'dylib' : 'so';
    final file = input.packageRoot.resolve('native/$slice/libsample_rust_core_flutter.$suffix');
    output.dependencies.add(file);
    output.assets.code.add(CodeAsset(
      package: input.packageName,
      name: 'sample_rust_core_flutter.dart',
      linkMode: DynamicLoadingBundled(),
      file: file,
    ));
  });
}
