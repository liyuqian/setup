import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

import 'default.dart';

class Cmd {
  /// Simple command that can be split by spaces without escapes.
  Cmd(String cmd, {String? path}) : this.args(cmd.split(' '), path: path);

  /// General commands with args list that may need escapes.
  const Cmd.args(this.cmdAndArgs, {this.path});

  /// Generate a list of simple commands.
  static List<Cmd> simpleLines(List<String> cmds, {String? path}) =>
      cmds.map((cmd) => Cmd(cmd, path: path)).toList(growable: false);

  final List<String> cmdAndArgs;
  final String? path;

  /// Return stdout or throw an error.
  Future<String> run({Logger? logger}) async {
    logger ??= defaultLogger;
    final pathInfo = path == null ? '' : ' in $path';
    logger.i('Running `${cmdAndArgs.join(' ')}` $pathInfo');
    final process = await Process.start(cmdAndArgs[0], cmdAndArgs.sublist(1),
        workingDirectory: path);
    final Stream<List<int>> broadcast = process.stdout.asBroadcastStream();
    final Future outDone = stdout.addStream(broadcast);
    final Future errDone = stderr.addStream(process.stderr);
    final String out = await broadcast.transform(utf8.decoder).join('\n');
    final int exitCode = await process.exitCode;
    await Future.wait([outDone, errDone]);
    if (exitCode != 0) {
      throw Exception('Unexpected exit code $exitCode');
    }
    return out;
  }
}

abstract class Check {
  const Check();
  Future<bool> test({Logger? logger});
}

class TrivialCheck extends Check {
  const TrivialCheck();
  @override
  test({Logger? logger}) async => true;
}

class CheckByCmd extends Check {
  const CheckByCmd(this.command, this.pass, {this.expectedExitCode = 0});
  final Cmd command;
  final bool Function(String stdout) pass;
  final int expectedExitCode;

  @override
  Future<bool> test({Logger? logger}) async {
    logger ??= defaultLogger;
    try {
      return pass(await command.run());
    } on Exception catch (e, stacktrace) {
      logger.e('$e\n\nStacktrace:\n$stacktrace');
      return false;
    }
  }
}

class FileCheck extends Check {
  const FileCheck(this.filepath, {this.sha512Prefix});
  final String filepath;
  final String? sha512Prefix;

  @override
  Future<bool> test({Logger? logger}) async {
    logger ??= defaultLogger;
    if (!File(filepath).existsSync()) {
      return false;
    }
    if (sha512Prefix == null) {
      return true;
    }
    final hash = sha512.convert(File(filepath).readAsBytesSync()).toString();
    final pass = hash.startsWith(sha512Prefix!);
    if (!pass) {
      logger.i('File $filepath has hash $hash without prefix $sha512Prefix');
    }
    return pass;
  }
}

class Setup {
  const Setup(this.name,
      {required this.commands, this.check = const TrivialCheck()});
  final String name;
  final List<Cmd> commands;
  final Check check;

  Future<void> apply({Logger? logger}) async {
    logger ??= defaultLogger;
    if (await check.test(logger: logger)) {
      logger.i('Setup "$name" already passed its check. Skpping.');
      return;
    }
    for (final cmd in commands) {
      await cmd.run(logger: logger);
    }
    if (!await check.test(logger: logger)) {
      throw Exception('Setup "$name" still has failed check after commands.');
    }
  }
}
