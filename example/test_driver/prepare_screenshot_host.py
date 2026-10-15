"""Create an isolated native Flutter host for the screenshot fixture."""

import json
from pathlib import Path
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parents[2]
host = root / "build" / "platform-screenshot-host"
platform = sys.argv[1]
assert platform in {"windows", "macos", "linux"}
subprocess.run(
    ["mise", "exec", "--", "flutter", "create", "--no-pub",
     f"--platforms={platform}", "--project-name=country_picker_capture", str(host)],
    cwd=root, check=True,
)
(host / "pubspec.yaml").write_text(
    "name: country_picker_capture\npublish_to: none\n"
    "environment:\n  sdk: '>=3.10.0 <4.0.0'\n"
    "dependencies:\n  flutter:\n    sdk: flutter\n"
    "  flutter_localizations:\n    sdk: flutter\n"
    "  cupertino_icons: ^1.0.8\n"
    f"  flutter_simple_country_picker:\n    path: {json.dumps(root.as_posix())}\n"
    "dev_dependencies:\n  flutter_test:\n    sdk: flutter\n"
    "  integration_test:\n    sdk: flutter\n"
    "flutter:\n  uses-material-design: true\n",
    encoding="utf-8",
)
for name in ["integration_test/platform_screenshots_test.dart",
             "test_driver/platform_screenshots_driver.dart"]:
    target = host / name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(root / "example" / name, target)
if platform == "macos":
    sdk = Path(subprocess.check_output(["mise", "where", "flutter"], cwd=root,
                                      text=True).strip())
    shutil.copy2(sdk / "packages/flutter_tools/templates/cocoapods/Podfile-macos",
                 host / "macos/Podfile")
    for configuration in ["Debug", "Release"]:
        config = host / f"macos/Flutter/Flutter-{configuration}.xcconfig"
        prefix = ('#include? "../Pods/Target Support Files/Pods-Runner/'
                  f'Pods-Runner.{configuration.lower()}.xcconfig"\n')
        config.write_text(prefix + config.read_text(), encoding="utf-8")
