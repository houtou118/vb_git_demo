import 'dart:io';

import '../vb_git_constant.dart';

// 是否在库工程运行脚本
Future<bool> isRunInMainProject() async {
  // 执行 `git rev-parse --show-toplevel` 以获取仓库的顶级目录路径
  final result = await Process.run('git', ['rev-parse', '--show-toplevel']);
  if (result.exitCode == 0) {
    // 获取并处理输出
    String repoPath = (result.stdout as String).trim();
    final currentPath = Directory.current.path;
    if (currentPath != repoPath) {
      print('$red请在壳工程根目录运行$reset');
      return false;
    } else {
      return true;
    }
  } else {
    print('Error: ${result.stderr}');
    return false;
  }
}

String? findProjectPath(String projectName) {
  var projectPath = projectName == 'InsightBank'
      ? Directory.current.path
      : '${Directory.current.path}/packages/$projectName';

  if (!Directory(projectPath).existsSync()) {
    projectPath = '${Directory.current.parent.path}/packages/$projectName';
    if (!Directory(projectPath).existsSync()) {
      return null;
    }
  }
  return projectPath;
}

List<String> getProjectNames(String type) {
  if (type == 'bis') {
    return vbBisProjectNames;
  } else if (type == 'plugin') {
    return vbPluginProjectNames;
  } else {
    return vbProjectNames;
  }
}

Future<String?> getCurrentBranchName(String projectPath) async {
  try {
    // 执行命令来获取当前分支名称
    final result = await Process.run(
      'git',
      ['-C', projectPath, 'rev-parse', '--abbrev-ref', 'HEAD'],
    );

    // 检查命令是否成功
    if (result.exitCode == 0) {
      // 返回分支名称，去掉末尾的换行符
      return result.stdout.trim();
    } else {
      // 输出错误信息
      print('获取分支名称失败: ${result.stderr}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
  return null;
}
