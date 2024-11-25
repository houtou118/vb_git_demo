import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../vb_git_constant.dart';
import 'vb_command.dart';

class VbGitBranchPullCommand extends Command<String> {
  VbGitBranchPullCommand() {
    argParser.addOption('type', abbr: 't', help: '仓库类型 (all, bis, plugin)');
  }

  @override
  String get name => 'pull';

  @override
  String get description => '拉取远端更新到本地';

  @override
  List<String> get aliases => ['bpl'];

  @override
  FutureOr<String>? run() async {
    final type = argResults?['type'];
    if (type == null || type.isEmpty) {
      print('$red错误: 必须提供 --type 参数来指定仓库类型(all, bis, plugin) $reset');
      return '';
    }
    await pullGitBranch(type);
    return '';
  }
}

Future<void> pullGitBranch(String type) async {
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
      if (branchName == null) {
        print('$projectName 拉取代码失败');
        continue;
      }
      // pull
      final pullResult = await Process.run(
        'git',
        ['-C', projectPath, 'pull', 'origin', branchName],
      );

      if (pullResult.exitCode == 0) {
        print('$green$projectName :$branchName$reset ${pullResult.stdout}');
      } else {
        print('$green$projectName :$reset\n$red${pullResult.stderr}$reset');
      }
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
