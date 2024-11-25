import 'dart:async';
import 'dart:io';

import '../vb_base_command.dart';
import '../vb_git_constant.dart';
import 'vb_command.dart';

class VbGitBranchSwitchCommand extends VbBaseCommand<String> {
  @override
  String get name => 'switch';

  @override
  String get description => '切换并拉取分支';

  @override
  List<String> get aliases => ['bs'];

  @override
  FutureOr<String>? run() async {
    final VbArgModel argModel = setupBaseValidate();
    if (argModel.isArgError) return '';
    await switchGitBranch(argModel.name!, argModel.type!);
    return '';
  }
}

/// 切换分支
Future<void> switchGitBranch(String branchName, String type) async {
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

      // 切换到新创建的分支
      final switchResult = await Process.run('git', ['-C', projectPath, 'checkout', branchName]);

      if (switchResult.exitCode == 0) {
        String projectStatus = (switchResult.stdout as String).trim();
        print('$green$projectName :$reset\n$projectStatus\n');
      } else {
        print('$red切换到新分支失败: ${switchResult.stderr}$reset');
      }
    }

    // // 遍历所有项目
    // for (var projectName in projectNames) {
    //   var projectPath = projectName == 'InsightBank'
    //       ? Directory.current.path
    //       : '${Directory.current.path}/packages/$projectName';

    //   // 检查子项目目录是否存在
    //   if (!Directory(projectPath).existsSync()) {
    //     projectPath = '${Directory.current.parent.path}/packages/$projectName';
    //     if (!Directory(projectPath).existsSync()) {
    //       print('$red目录不存在: $projectName$reset');
    //       continue;
    //     }
    //   }

    //   // 切换到新创建的分支
    //   final switchResult = await Process.run('git', ['-C', projectPath, 'checkout', branchName]);

    //   if (switchResult.exitCode == 0) {
    //     String projectStatus = (switchResult.stdout as String).trim();
    //     print('$green$projectName :$reset\n$projectStatus\n');
    //   } else {
    //     print('$red切换到新分支失败: ${switchResult.stderr}$reset');
    //   }
    // }
  } catch (e) {
    print('An error occurred: $e');
  }
}
