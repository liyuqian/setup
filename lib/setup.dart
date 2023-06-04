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

class False extends Check {
  const False();
  @override
  test({Logger? logger}) async => false;
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

abstract class Setup {
  const Setup(this.name, {this.check = const False()});
  final String name;
  final Check check;
  Future<void> _doApply(Logger logger);
  Future<void> apply({Logger? logger}) async {
    logger ??= defaultLogger;
    if (await check.test(logger: logger)) {
      logger.i('Setup "$name" already passed its check. Skpping.');
      return;
    }
    await _doApply(logger);
    if (!await check.test(logger: logger)) {
      throw Exception('Setup "$name" still has failed check after commands.');
    }
  }
}

class SetupByCmds extends Setup {
  const SetupByCmds(super.name, {required this.commands, super.check});
  final List<Cmd> commands;
  @override
  Future<void> _doApply(Logger logger) async {
    for (final cmd in commands) {
      await cmd.run(logger: logger);
    }
  }
}

class AptInstall extends SetupByCmds {
  AptInstall(this.package)
      : super(
          'apt install $package',
          commands: [Cmd('sudo apt install -y $package')],
          check: CheckByCmd(
            Cmd('apt list --installed $package'),
            (stdout) => stdout.contains('installed'),
          ),
        );
  final String package;
}

class ConfigFileCheck extends Check {
  const ConfigFileCheck(this.filepath, this.lines);

  final String filepath;
  final List<String> lines;

  @override
  Future<bool> test({Logger? logger}) async {
    final fileLines = File(filepath).readAsLinesSync().map((x) => x.trim());
    return lines.every((line) => fileLines.contains(line.trim()));
  }
}

class ConfigFileSetup extends Setup {
  ConfigFileSetup(String name, {required this.filepath, required this.lines})
      : super(name, check: ConfigFileCheck(filepath, lines));

  final String filepath;
  final List<String> lines;

  @override
  Future<void> _doApply(Logger logger) async {
    final hash = sha512.convert(File(filepath).readAsBytesSync()).toString();
    final backupName = '$filepath.bak.${hash.substring(0, 8)}';
    logger.i('Backing up $filepath to $backupName');
    File(filepath).copySync(backupName);
    final fileLines = File(filepath).readAsLinesSync();
    fileLines.addAll(lines);
    File(filepath).writeAsStringSync('${fileLines.join('\n')}\n');
  }
}
