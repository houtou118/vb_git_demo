import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../vb_git_constant.dart';

class VbGitCloneCommand extends Command<String> {
  VbGitCloneCommand();

  @override
  String get name => 'clone';

  @override
  String get description => '克隆所有仓库';

  @override
  List<String> get aliases => ['cl'];

  @override
  FutureOr<String>? run() async {
    gitClone();
    return '';
  }

  Future<void> gitClone() async {
    final insightBankRepo = vbProjectGitMap[insightBank];
    await cloneRepository(insightBank, insightBankRepo!, '.');

    // Enter the insightBank directory
    final insightBankDir = Directory('InsightBank');
    if (!insightBankDir.existsSync()) {
      print('$red InsightBank directory not found! $reset');
      return;
    }

    // Create the packages directory
    final packagesDir = Directory('${insightBankDir.path}/packages');
    if (!packagesDir.existsSync()) {
      packagesDir.createSync();
    }

    // Clone all sub-projects into the packages directory
    for (var entry in vbProjectGitMap.entries) {
      if (entry.key != insightBank) {
        await cloneRepository(entry.key, entry.value, packagesDir.path);
      }
    }
  }

  Future<void> cloneRepository(String repoNmae, String repoUrl, String targetDirectory) async {
    final animation = AnimatedDots();
    animation.start(repoNmae);
    final process = await Process.run('git', ['clone', repoUrl], workingDirectory: targetDirectory);

    final exitCode = process.exitCode;
    animation.stop();
    if (exitCode == 0) {
      print('$green 成功克隆仓库 $reset$repoUrl');
    } else {
      print('$red 克隆仓库失败 $reset $repoUrl');
    }
  }
}

class AnimatedDots {
  Timer? _timer;
  int _dotCount = 0;

  void start(String repoNmae) {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      stdout.write('\r$repoNmae 仓库克隆中${'.' * (_dotCount % 4)}   ');
      _dotCount++;
    });
  }

  void stop() {
    _timer?.cancel();
    stdout.write('\r');
  }
}
