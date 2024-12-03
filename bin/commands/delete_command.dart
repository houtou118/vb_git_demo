import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../vb_git_constant.dart';
import 'vb_command.dart';

class VbGitBranchDeleteCommand extends Command<String> {
  VbGitBranchDeleteCommand() {
    argParser.addOption('type', abbr: 't', help: '仓库类型 (all, bis, plugin, ft)');
    argParser.addOption('name', abbr: 'n', help: '操作的分支名称');
    argParser.addFlag('origin', abbr: 'o', defaultsTo: false, help: '是否删除远程分支，默认不删除');
  }

  @override
  String get name => 'delete';

  @override
  String get description => '删除分支';

  @override
  List<String> get aliases => ['bd'];

  @override
  FutureOr<String>? run() async {
    final type = argResults?['type'];
    if (type == null || type.isEmpty) {
      print('$red错误: 必须提供 --type 参数来指定仓库类型(all, bis, plugin, ft) $reset');
    }

    //检查是否提供了 `--name` 参数
    final name = argResults?['name'];
    if (name == null || name.isEmpty) {
      // throw UsageException('错误: 必须提供 --name 参数来指定分支名称', usage);
      print('$red错误: 必须提供 --name 参数来指定分支名称$reset');
      return '';
    }

    final origin = argResults?['origin'] as bool;
    print('origin: $origin');

    await deleteBranch(name, type, isOrigin: origin);
    return '';
  }
}

Future<void> deleteBranch(String branchName, String type, {bool isOrigin = false}) async {
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

      await deleteLocalBranch(projectPath, projectName, branchName);
      if (isOrigin) {
        await deleteRemoteBranch(projectPath, projectName, branchName);
      }
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

Future<void> deleteLocalBranch(String projectPath, String projectName, String branchName) async {
  // 删除分支
  final deleteResult = await Process.run(
    'git',
    ['-C', projectPath, 'branch', '-D', branchName],
  );

  if (deleteResult.exitCode == 0) {
    print('$green$projectName 删除本地分支成功 $yellow$branchName$reset');
  } else {
    print('$green $projectName $reset 删除本地分支失败: $red${deleteResult.stderr}$reset');
  }
}

Future<void> deleteRemoteBranch(String projectPath, String projectName, String branchName) async {
  // 删除分支
  final deleteResult = await Process.run(
    'git',
    ['-C', projectPath, 'push', 'origin', '--delete', branchName],
  );

  if (deleteResult.exitCode == 0) {
    print('$green$projectName 删除远程分支成功 $yellow$branchName$reset');
  } else {
    print('$green $projectName $reset 删除远程分支失败: $red${deleteResult.stderr}$reset');
  }
}
