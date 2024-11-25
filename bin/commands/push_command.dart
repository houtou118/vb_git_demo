import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../vb_git_constant.dart';
import 'vb_command.dart';

class VbGitBranchPushCommand extends Command<String> {
  VbGitBranchPushCommand() {
    argParser.addOption('type', abbr: 't', help: '仓库类型 (all, bis, plugin)');
  }

  @override
  String get name => 'push';

  @override
  String get description => '推送本地分支到远端';

  @override
  List<String> get aliases => ['bps'];

  @override
  FutureOr<String>? run() async {
    final type = argResults?['type'];
    if (type == null || type.isEmpty) {
      print('$red错误: 必须提供 --type 参数来指定仓库类型(all, bis, plugin) $reset');
      return '';
    }

    await pushGitBranch(type);
    return '';
  }
}

Future<void> pushGitBranch(String type) async {
  try {
    final isCorrectDir = await isRunInMainProject();
    if (!isCorrectDir) return;

    List<String> projectNames = getProjectNames(type);

    for (var projectName in projectNames) {
      final projectPath = findProjectPath(projectName);
      if (projectPath == null) {
        print('$red目录不存在: $projectName$reset');
        continue;
      }

      final branchName = await getCurrentBranchName(projectPath);
      final pushResult = await Process.run('git', [
        '-C',
        projectPath,
        'push',
        'origin',
        branchName!,
      ]);

      if (pushResult.exitCode == 0) {
        print('$green$projectName :$branchName$reset ${pushResult.stdout}\n');
      } else {
        print('$green$projectName :$reset\n$red${pushResult.stderr}$reset');
      }
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
