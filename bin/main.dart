import 'package:args/command_runner.dart';

import 'commands/clone_command.dart';
import 'commands/create_command.dart';
import 'commands/delete_command.dart';
import 'commands/merge_command.dart';
import 'commands/pull_command.dart';
import 'commands/push_command.dart';
import 'commands/status_command.dart';
import 'commands/switch_command.dart';

void main(List<String> args) async {
  final runner = CommandRunner<String>(
    'vb_git_helper',
    'VB App 分支管理工具',
  )
    ..addCommand(VbGitCloneCommand())
    ..addCommand(VbGitBranchStatusCommand())
    ..addCommand(VbGitBranchSwitchCommand())
    ..addCommand(VbGitBranchPushCommand())
    ..addCommand(VbGitBranchPullCommand())
    ..addCommand(VbGitBranchDeleteCommand())
    ..addCommand(VbGitBranchCreteCommand())
    ..addCommand(VbGitBranchMergeCommand());

  try {
    final output = await runner.run(args);
    if (output != null) print(output);
    print('');
  } on UsageException catch (e) {
    // 自定义错误信息并抑制堆栈信息
    print(e.message);
  } catch (e) {
    // 捕获其他异常
    print('发生了未处理的错误: $e');
  }
}
