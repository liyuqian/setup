class Cmd {
  const Cmd(this.cmdAndArgs, {this.path});
  final List<String> cmdAndArgs;
  final String? path;

  Cmd.simple(String cmd, {this.path})
      : cmdAndArgs = cmd.split(' ').toList(growable: false);

  static List<Cmd> simpleLines(List<String> cmds, {String? path}) =>
      cmds.map((cmd) => Cmd.simple(cmd, path: path)).toList(growable: false);
}

class Check {
  const Check(this.command, this.pass, {this.expectedExitCode = 0});
  final Cmd command;
  final bool Function(String stdout) pass;
  final int expectedExitCode;
}

class Setup {
  const Setup(this.name, {required this.commands, this.check});
  final String name;
  final List<Cmd> commands;
  final Check? check;
}
