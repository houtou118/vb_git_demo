import 'package:args/command_runner.dart';

import 'vb_git_constant.dart';

class VbArgModel {
  final String? name;
  final String? type;

  VbArgModel({
    this.name,
    this.type,
  });

  bool get isArgError => (type?.isEmpty ?? true) || (name?.isEmpty ?? true);
}

abstract class VbBaseCommand<String> extends Command<String> {
  VbBaseCommand() {
    addCommonOptions();
  }

  /// 添加通用选项
  void addCommonOptions() {
    argParser.addOption('type', abbr: 't', help: '仓库类型 (all, bis, plugin, ft)');
    argParser.addOption('name', abbr: 'n', help: '分支名称');
  }

  VbArgModel setupBaseValidate() {
    final type = argResults?['type'];
    if (type == null || type.isEmpty) {
      print('$red错误: 必须提供 --type 参数来指定仓库类型(all, bis, plugin, ft) $reset');
    }

    //检查是否提供了 `--name` 参数
    final name = argResults?['name'];
    if (name == null || name.isEmpty) {
      print('$red错误: 必须提供 --name 参数来指定分支名称$reset');
    }

    return VbArgModel(name: name, type: type);
  }
}
