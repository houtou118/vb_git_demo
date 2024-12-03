import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../vb_git_constant.dart';
import 'vb_command.dart';

class VbGitBranchMergeCommand extends Command<String> {
  VbGitBranchMergeCommand() {
    argParser.addOption('type', abbr: 't', help: '仓库类型 (all, bis, plugin, ft)');
    argParser.addOption('name', abbr: 'n', help: '指定分支名称');
  }

  @override
  String get name => 'merge';

  @override
  String get description => '合并指定分支到当前分支';

  @override
  List<String> get aliases => ['mr'];

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

    await excuteMerge(name, type);
    return '';
  }

  Future<void> excuteMerge(String branchName, String type) async {
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
        await mergeBranch(projectPath, branchName, type);
      }
    } catch (e) {
      print('An error occurred: $e');
      return;
    }
  }

  Future<void> mergeBranch(String projectPath, String branch, String type) async {
    print('$green$projectPath$reset Merging branch $branch into current branch...');

    final process = await Process.start(
      'git',
      ['merge', '--no-ff', branch],
      workingDirectory: projectPath,
    );

    final exitCode = await process.exitCode;
    if (exitCode == 0) {
      print('Merge completed successfully.');
    } else {
      print('$red Merge failed with exit code $reset$exitCode.');
    }
  }
}
