/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 28 February 2025
 */

import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:l/l.dart';

/// Creates and pushes the tag for the version in `pubspec.yaml`.
///
/// Run with `mise exec -- dart run tool/dart/tag.dart`.
void main() => runZonedGuarded<void>(
  () async {
    // Only tag a committed revision the upstream branch already contains.
    final statusResult = await Process.run('git', ['status', '--porcelain']);
    if (_readStdout(statusResult).trim().isNotEmpty) {
      l.e('There are uncommitted changes.');
      exit(1);
    }
    final aheadResult = await Process.run('git', [
      'rev-list',
      '--count',
      '@{u}..HEAD',
    ]);
    if (aheadResult.exitCode != 0 || _readStdout(aheadResult).trim() != '0') {
      l.e('There are unpushed changes.');
      exit(1);
    }

    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      l.w('File pubspec.yaml not found.');
      exit(1);
    }
    final pubspecContent = pubspecFile.readAsLinesSync();
    final versionLine = pubspecContent.firstWhereOrNull(
      (line) => line.trim().startsWith('version:'),
    );
    if (versionLine == null) {
      l.e('Version not found in pubspec.yaml.');
      exit(1);
    }
    final version = versionLine.split(':')[1].trim();
    l.i('Found version: $version');

    final versionParts = version.split('.');
    if (versionParts.length != 3 ||
        versionParts.any((e) => int.tryParse(e) == null)) {
      l.e('Invalid version format: $version');
      exit(1);
    }

    final tagName = 'v$version';
    final tagResult = await Process.run('git', ['tag', '-l', tagName]);
    if (tagResult.stdout?.toString().trim() == tagName) {
      l.e('Tag $tagName already exists.');
      exit(1);
    }

    await _runGitCommand(['tag', tagName]);
    l.i('Tag $tagName created.');

    await _runGitCommand(['push', 'origin', tagName]);
    l.i('Tag $tagName pushed to remote repository.');
  },
  (e, st) {
    l.e('Unexpected error: $e', st);
    exit(1);
  },
);

/// Reads text output without accepting a binary or missing git response.
String _readStdout(ProcessResult result) => switch (result.stdout) {
  String output => output,
  _ => throw StateError('Expected text output from git.'),
};

/// Runs a git command and stops the release helper when it fails.
Future<void> _runGitCommand(List<String> args) async {
  final result = await Process.run('git', args);
  if (result.exitCode == 0) return;
  l.e('Error running git ${args.join(" ")}: ${result.stderr}');
  exit(1);
}
