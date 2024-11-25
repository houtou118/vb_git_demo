import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../vb_base_command.dart';
import '../vb_git_constant.dart';
import 'vb_command.dart';

class VbGitBranchCreteCommand extends VbBaseCommand<String> {
  @override
  String get name => 'create';

  @override
  String get description => '创建新分支';

  @override
  List<String> get aliases => ['bc'];

  @override
  FutureOr<String>? run() async {
    final VbArgModel argModel = setupBaseValidate();
    if (argModel.isArgError) return '';
    final bcRes = await gitBranchCreate(type: argModel.type!, name: argModel.name!);
    if (!bcRes) {
      print('新创建新分支失败');
    }
    return '';

    /* 这段代码后续可能会用到   
    if (argModel.type == 'plugin') return '';

    // 修改壳工程的pubspec.yaml依赖
    final Map<String, String>? originalMap = await fetchBisGitCommitId();
    if (originalMap == null) {
      print('$yellow 未能成功修改pubspec.yaml的引用');
      return '';
    }

    // 将 Map 转为 JSON 字符串
    final Map<String, dynamic> vbBranchConfigMap = {
      'branchName': argModel.name,
      'config': originalMap,
    };
    String jsonString = jsonEncode(vbBranchConfigMap);
    // 创建文件并将 JSON 写入其中
    File jsonFile = File('vb_branch_config.json');
    await jsonFile.writeAsString(jsonString);

    // 判断 pubspec.yaml 是否存在
    final currentDirectory = Directory.current;
    final filePath = '${currentDirectory.path}/pubspec.yaml';
    final file = File(filePath);
    final isFileExists = file.existsSync();
    if (!isFileExists) {
      print('不存在 pubspec.yaml 文件');
    }

    // 定义两个新 Map
    Map<String, String> map1 = {};
    Map<String, String> map2 = {};

    // 指定 map1 的键
    Set<String> map1Keys = {'vb_basic', 'vb_bank', 'vb_fund'};

    // 拆分 Map
    originalMap.forEach((key, value) {
      if (map1Keys.contains(key)) {
        map1[key] = value;
      } else {
        map2[key] = value;
      }
    });

    await modifyPluginRefs(file, map1);
    await writeDependenciesToYaml(file, map2);

    return '';
    */
  }
}

Future<bool> gitBranchCreate({required String type, required String name}) async {
  try {
    final isCorrectDir = await isRunInMainProject();
    if (!isCorrectDir) return false;

    List<String> projectNames = getProjectNames(type);

    for (var projectName in projectNames) {
      final projectPath = findProjectPath(projectName);
      if (projectPath == null) {
        print('$red目录不存在: $projectName$reset');
        continue;
      }

      if (await createAndCheckoutBranch(projectPath, name)) {
        print('$blue$projectName 成功创建并切换到分支 $yellow$name$reset');
      } else {
        print('$red$projectName 创建或切换分支失败$reset');
        return false;
      }
    }
    return true;
  } catch (e) {
    print('An error occurred: $e');
    return false;
  }
}

Future<bool> createAndCheckoutBranch(String projectPath, String branchName) async {
  // 创建新的 Git 分支
  final result = await Process.run('git', ['-C', projectPath, 'branch', branchName]);

  // 检查命令是否成功
  if (result.exitCode != 0) {
    print('创建分支失败: ${result.stderr}');
    return false;
  }

  // 切换到新创建的分支
  final switchResult = await Process.run('git', ['-C', projectPath, 'checkout', branchName]);

  if (switchResult.exitCode == 0) {
    return true;
  } else {
    print('切换到新分支失败: ${switchResult.stderr}');
    return false;
  }
}

Future<void> modifyPluginRefs(File file, Map<String, String> pluginRefs) async {
  try {
    // 读取文件内容
    String content = await file.readAsString();

    // 对每个插件进行匹配和替换
    pluginRefs.forEach((pluginName, newRef) {
      // 创建正则表达式匹配插件及其 ref
      final regex = RegExp(
        r'(' + pluginName + r':\s*\n\s*git:\s*\n\s*url:\s*.*\s*\n\s*ref:\s*)(.+)',
        multiLine: true,
      );

      // 替换 ref
      content = content.replaceAllMapped(regex, (match) {
        return '${match.group(1)}$newRef';
      });
    });

    // 将修改后的内容写回文件
    await file.writeAsString(content);
    print('文件内容已修改');
  } catch (e) {
    print('修改文件时发生错误: $e');
  }
}

Future<void> writeDependenciesToYaml(File file, Map<String, String> dependencies) async {
  // 读取 pubspec.yaml 文件
  String content = await file.readAsString();

  // 解析 YAML
  final yamlMap = loadYaml(content);
  final yamlEditor = YamlEditor(content);

  // 检查是否存在 dependency_overrides
  if (!yamlMap.containsKey('dependency_overrides')) {
    // 如果不存在，初始化为一个空的 Map
    yamlEditor.update(['dependency_overrides'], {});
  }

  // 添加新的依赖
  dependencies.forEach((name, ref) {
    yamlEditor.update([
      'dependency_overrides',
      name
    ], {
      'git': {
        'url': 'git@gitlab.futunn.com:bank_client/$name.git',
        'ref': ref,
      }
    });
  });

  // 将修改后的内容写回文件
  await file.writeAsString(yamlEditor.toString());
  print('依赖项已添加到 dependency_overrides');
}

Future<Map<String, String>?> fetchBisGitCommitId() async {
  try {
    final isCorrectDir = await isRunInMainProject();
    if (!isCorrectDir) return null;

    Map<String, String> commitIds = {};

    for (var projectName in vbBisProjectNames) {
      if (projectName == 'InsightBank') continue;
      var projectPath = '${Directory.current.path}/packages/$projectName';
      // 检查子项目目录是否存在
      if (!Directory(projectPath).existsSync()) {
        projectPath = '${Directory.current.parent.path}/packages/$projectName';
        if (!Directory(projectPath).existsSync()) {
          print('$red目录不存在: $projectName$reset');
          continue;
        }
      }

      // 获取当前分支名
      final branchResult = await Process.run('git', ['rev-parse', '--abbrev-ref', 'HEAD'],
          workingDirectory: projectPath);
      if (branchResult.exitCode != 0) {
        print('获取分支名失败: ${branchResult.stderr}');
        return null;
      }

      // 获取最新的提交ID
      final commitResult =
          await Process.run('git', ['rev-parse', 'HEAD'], workingDirectory: projectPath);
      if (commitResult.exitCode != 0) {
        print('获取提交ID失败: ${commitResult.stderr}');
        return null;
      }
      final commitId = commitResult.stdout.trim();
      commitIds[projectName] = commitId;
    }

    return commitIds;
  } catch (e) {
    print('An error occurred: $e');
    return null;
  }
}
