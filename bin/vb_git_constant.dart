// ANSI 转义码
const String reset = '\x1B[0m'; // 重置所有属性
const String red = '\x1B[31m'; // 红色前景
const String green = '\x1B[32m'; // 绿色前景
const String yellow = '\x1B[33m'; // 黄色前景
const String blue = '\x1B[34m'; // 蓝色前景

const String gitAddressPrefix = 'git@gitlab.futunn.com:bank_client';

const String insightBank = 'InsightBank';
const String vbBasic = 'vb_basic';
const String vbBank = 'vb_bank';
const String vbFund = 'vb_fund';
const String vbBusinessPlatform = 'vb_business_platform';
const String vbFramework = 'vb_framework';
const String flutterUikit = 'flutter_uikit';
const String miFlutterPlugins = 'mi_flutter_plugins';
const String vbCommonBusiness = 'vb_common_business';
const String ftFlutterUiKit = 'ft_flutter_ui_kit';
const String ftFlutterRes = 'ft_flutter_res';

const Map<String, String> vbProjectGitMap = {
  insightBank: 'git@gitlab.futunn.com:bank_client/InsightBank.git',
  vbBasic: 'git@gitlab.futunn.com:bank_client/vb_basic.git',
  vbBank: 'git@gitlab.futunn.com:bank_client/vb_bank.git',
  vbFund: 'git@gitlab.futunn.com:bank_client/vb_fund.git',
  vbBusinessPlatform: 'git@gitlab.futunn.com:bank_client/vb_business_platform.git',
  vbFramework: 'git@gitlab.futunn.com:bank_client/vb_framework.git',
  flutterUikit: 'git@gitlab.futunn.com:bank_client/flutter_uikit.git',
  miFlutterPlugins: 'git@gitlab.futunn.com:bank_client/mi_flutter_plugins.git',
  vbCommonBusiness: 'git@gitlab.futunn.com:bank_client/vb_common_business.git',
  ftFlutterUiKit: 'git@gitlab.futunn.com:flutter/basic/ft_flutter_ui_kit.git',
  ftFlutterRes: 'git@gitlab.futunn.com:flutter/basic/ft_flutter_res.git',
};

const List<String> vbProjectNames = [
  insightBank,
  vbBasic,
  vbBank,
  vbFund,
  vbBusinessPlatform,
  vbFramework,
  flutterUikit,
  miFlutterPlugins,
  vbCommonBusiness,
  ftFlutterUiKit,
  ftFlutterRes,
];
const String vbMainProjectName = insightBank;

const List<String> vbPackagesProjectNames = [
  vbBasic,
  vbBank,
  vbFund,
  vbBusinessPlatform,
  vbFramework,
  flutterUikit,
  miFlutterPlugins,
  vbCommonBusiness,
  ftFlutterUiKit,
  ftFlutterRes,
];

const List<String> vbBisProjectNames = [
  insightBank,
  vbBasic,
  vbBank,
  vbFund,
  vbBusinessPlatform,
  vbFramework,
];
const List<String> vbPluginProjectNames = [
  flutterUikit,
  miFlutterPlugins,
  vbCommonBusiness,
  ftFlutterUiKit,
  ftFlutterRes,
];
const List<String> ftProjectNames = [
  ftFlutterUiKit,
  ftFlutterRes,
];
