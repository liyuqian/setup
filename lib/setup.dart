import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import 'default.dart';

String get home => Platform.environment['HOME']!;

const String kRawGithubRoot = 'https://raw.githubusercontent.com';

class ExitCodeError extends Error {
  ExitCodeError(this.exitCode);
  final int exitCode;
  @override
  String toString() => 'Unexpected exit code $exitCode';
}

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
  Future<String> run({Logger? logger, bool streamOut = true}) async {
    logger ??= defaultLogger;
    final pathInfo = path == null ? '' : ' in $path';
    logger.i('Running `${cmdAndArgs.join(' ')}` $pathInfo');
    final process = await Process.start(cmdAndArgs[0], cmdAndArgs.sublist(1),
        workingDirectory: path);
    final Stream<List<int>> broadcast = process.stdout.asBroadcastStream();
    final List<Future> futures = [];
    if (streamOut) {
      futures.add(stdout.addStream(broadcast));
    }
    futures.add(stderr.addStream(process.stderr));
    final String out = await broadcast.transform(utf8.decoder).join('\n');
    final int exitCode = await process.exitCode;
    await Future.wait(futures);
    if (exitCode != 0) {
      throw ExitCodeError(exitCode);
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
  const CheckByCmd(this.command, this.pass,
      {this.okExitCodes = const [0], this.muteCmdNotFound = false});
  final Cmd command;
  final bool Function(String stdout) pass;
  final List<int> okExitCodes;
  final bool muteCmdNotFound;

  @override
  Future<bool> test({Logger? logger}) async {
    logger ??= defaultLogger;
    try {
      return pass(await command.run(streamOut: false));
    } on ExitCodeError catch (e, stacktrace) {
      if (!okExitCodes.contains(e.exitCode)) {
        logger.e('$e\n\nStacktrace:\n$stacktrace');
      }
      return false;
    } on ProcessException catch (e, stacktrace) {
      if (!muteCmdNotFound || e.errorCode != 2) {
        logger.e('$e\n\nStacktrace:\n$stacktrace');
      }
      return false;
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
    if (sha512Prefix == null && Directory(filepath).existsSync()) {
      return true;
    }
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

  Future<void> apply({Logger? logger}) async {
    logger ??= defaultLogger;
    if (await check.test(logger: logger)) {
      logger.i('Setup "$name" already passed its check. Skpping.');
      return;
    }
    await doApply(logger);
    if (!await check.test(logger: logger)) {
      throw Exception('Setup "$name" still has failed check after commands.');
    }
  }

  static void backupFile(String filepath, Logger logger) {
    if (!File(filepath).existsSync()) {
      return;
    }
    final hash = sha512.convert(File(filepath).readAsBytesSync()).toString();
    final backupName = '$filepath.bak.${hash.substring(0, 8)}';
    logger.i('Backing up $filepath to $backupName');
    File(filepath).copySync(backupName);
  }

  @protected
  Future<void> doApply(Logger logger);
}

class SetupByCmds extends Setup {
  const SetupByCmds(super.name, {required this.commands, super.check});
  final List<Cmd> commands;
  @override
  Future<void> doApply(Logger logger) async {
    for (final cmd in commands) {
      await cmd.run(logger: logger);
    }
  }
}

class AptInstall extends SetupByCmds {
  AptInstall(this.package)
      : super(
          'apt install $package',
          commands: [Cmd('sudo apt-get install -y $package')],
          check: CheckByCmd(
            Cmd('dpkg-query --status $package'),
            (stdout) => stdout.contains('installed'),
            okExitCodes: [0, 1],
          ),
        );
  final String package;
}

class GetOmzPlugin extends SetupByCmds {
  GetOmzPlugin(String name)
      : super(
          'get oh-my-zsh plugin $name',
          commands: [
            Cmd.args([
              'git',
              'clone',
              'https://github.com/zsh-users/$name',
              '$home/.oh-my-zsh/custom/plugins/$name',
            ]),
          ],
          check: FileCheck('$home/.oh-my-zsh/custom/plugins/$name/README.md'),
        );
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
  Future<void> doApply(Logger logger) async {
    Setup.backupFile(filepath, logger);
    final fileLines = File(filepath).readAsLinesSync();
    fileLines.addAll(lines);
    File(filepath).writeAsStringSync('${fileLines.join('\n')}\n');
  }
}

class DownloadFile extends SetupByCmds {
  DownloadFile(String name,
      {required this.path, required String url, required String sha512Prefix})
      : super(
          name,
          commands: [
            Cmd.args(['curl', url, '-o', path])
          ],
          check: FileCheck(path, sha512Prefix: sha512Prefix),
        );

  final String path;

  @override
  Future<void> doApply(Logger logger) async {
    Setup.backupFile(path, logger);
    return await super.doApply(logger);
  }
}
