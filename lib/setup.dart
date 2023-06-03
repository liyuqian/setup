import 'dart:convert';
import 'dart:io';

class Cmd {
  /// Simple command that can be simply split by spaces.
  Cmd(String cmd, {String? path}) : this.args(cmd.split(' '), path: path);

  /// General commands with args list that may need escapes.
  const Cmd.args(this.cmdAndArgs, {this.path});

  /// Generate a list of simple commands.
  static List<Cmd> simpleLines(List<String> cmds, {String? path}) =>
      cmds.map((cmd) => Cmd(cmd, path: path)).toList(growable: false);

  final List<String> cmdAndArgs;
  final String? path;

  /// Return stdout or throw an error.
  Future<String> run() async {
    final process = await Process.start(cmdAndArgs[0], cmdAndArgs.sublist(1),
        workingDirectory: path);
    final broadcast = process.stdout.asBroadcastStream();
    final outDone = stdout.addStream(broadcast);
    final errDone = stderr.addStream(process.stderr);
    final int exitCode = await process.exitCode;
    await Future.wait([outDone, errDone]);
    if (exitCode != 0) {
      throw Exception('Unexpected exit code $exitCode');
    }
    return (await broadcast.transform(utf8.decoder).toList()).join('\n');
  }
}

class Check {
  const Check(this.command, this.pass, {this.expectedExitCode = 0});
  final Cmd command;
  final bool Function(String stdout) pass;
  final int expectedExitCode;

  Future<bool> test() async {
    try {
      return pass(await command.run());
    } catch (e) {
      return false;
    }
  }
}

class Setup {
  const Setup(this.name, {required this.commands, this.check});
  final String name;
  final List<Cmd> commands;
  final Check? check;
}
