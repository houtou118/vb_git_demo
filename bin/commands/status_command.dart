import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../vb_git_constant.dart';
import 'vb_command.dart';

class VbGitBranchStatusCommand extends Command<String> {
  @override
  String get name => 'status';

  @override
  String get description => '分支状态';

  @override
  List<String> get aliases => ['st'];

  @override
  FutureOr<String>? run() {
    gitSt();
    return '';
  }
}

void gitSt() async {
  // print('打印所有工程当前分支状态');
  try {
    final isCorrectDir = await isRunInMainProject();
    if (!isCorrectDir) return;

    // 遍历所有项目
    for (var projectName in vbProjectNames) {
      var projectPath = projectName == 'InsightBank'
          ? Directory.current.path
          : '${Directory.current.path}/packages/$projectName';

      // 检查子项目目录是否存在
      if (!Directory(projectPath).existsSync()) {
        projectPath = '${Directory.current.parent.path}/packages/$projectName';
        if (!Directory(projectPath).existsSync()) {
          print('$red目录不存在: $projectName$reset');
          continue;
        }
      }

      // 获取项目的 Git 状态
      var projectResult = await Process.run('git', ['-C', projectPath, 'status']);

      if (projectResult.exitCode == 0) {
        String projectStatus = (projectResult.stdout as String).trim();
        print('$green$projectName :$reset\n$projectStatus');
      } else {
        print('${red}Error retrieving status for $projectName: ${projectResult.stderr}$reset');
      }
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
