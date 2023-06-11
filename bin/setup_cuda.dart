import 'package:setup/setup.dart';

const String kCudaWsl =
    'https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu';
const String kWslPinName = 'cuda-wsl-ubuntu.pin';
final cudaWslCmds = Cmd.simpleLines([
      'wget $kCudaWsl/x86_64/$kWslPinName',
      'sudo mv $kWslPinName /etc/apt/preferences.d/cuda-repository-pin-600',
      'sudo apt-key adv --fetch-keys $kCudaWsl/x86_64/3bf863cc.pub',
    ]) +
    [
      Cmd.args([
        'sudo',
        'add-apt-repository',
        'deb $kCudaWsl/x86_64/ /',
      ])
    ] +
    Cmd.simpleLines([
      'sudo apt-get update',
      'sudo apt-get -y install cuda=11.7.1-1',
    ]);

final installCudaWsl_11_7 = SetupByCmds(
  'install cuda 11.7',
  commands: cudaWslCmds,
);

const String kCuda2004 =
    'https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004';
final installCuda_11_7 = SetupByCmds(
  'install cuda 11.7',
  commands: Cmd.simpleLines([
      'wget $kCuda2004/x86_64/cuda-keyring_1.0-1_all.deb -O /tmp/cuda.deb',
      'sudo dpkg -i /tmp/cuda.deb',
      'sudo apt-get update',
      'sudo apt-get -y install cuda=11.7.1-1',
    ]),
);
