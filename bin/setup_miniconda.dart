import 'dart:io';

import 'package:logger/src/logger.dart';
import 'package:setup/collection.dart';

Future<void> main() async {
  await setUpConda();
}

Future<void> setUpConda() async {
  await installMiniconda.apply();
  await CondaZshrcSetup().apply();
}

const kScriptUrl =
    'https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh';
final installMiniconda = SetupByCmds('install miniconda',
    commands: Cmd.simpleLines([
      'wget $kScriptUrl -O /tmp/miniconda.sh',
      'chmod +x /tmp/miniconda.sh',
      '/tmp/miniconda.sh -b',
    ]),
    check: FileCheck('$home/miniconda3/bin/conda'));

class CondaZshrcCheck extends Check {
  @override
  Future<bool> test({Logger? logger}) async {
    if (!File(kRcFilename).existsSync()) {
      return false;
    }
    final lines = File(kRcFilename).readAsLinesSync();
    final header = kCondaZshrcSnippet.split('\n')[0];
    return lines.contains(header);
  }

  static final String kRcFilename = '$home/.zshrc.local';
}

class CondaZshrcSetup extends Setup {
  CondaZshrcSetup() : super('config zshrc for conda', check: CondaZshrcCheck());

  @override
  Future<void> doApply(Logger logger) async {
    final String filename = CondaZshrcCheck.kRcFilename;
    logger.i('Append conda zshrc snippet to $filename');
    String content = kCondaZshrcSnippet;
    if (File(filename).existsSync()) {
      content = '\n$content';
    }
    File(filename).writeAsStringSync(content, mode: FileMode.append);
  }
}

const kCondaZshrcSnippet = r'''
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/liyuqian/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/liyuqian/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/liyuqian/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/liyuqian/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
''';
