import 'package:flutter/material.dart';
import 'package:focus_timer/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 番茄钟设置
          _buildSectionTitle('番茄钟设置'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingItem(
              '专注时长',
              '25',
              '分钟',
              () => _showDurationDialog(context, '专注时长', 25, (value) {}),
            ),
            _buildDivider(),
            _buildSettingItem(
              '短休息时长',
              '5',
              '分钟',
              () => _showDurationDialog(context, '短休息时长', 5, (value) {}),
            ),
            _buildDivider(),
            _buildSettingItem(
              '长休息时长',
              '15',
              '分钟',
              () => _showDurationDialog(context, '长休息时长', 15, (value) {}),
            ),
            _buildDivider(),
            _buildSettingItem(
              '长休息间隔',
              '4',
              '个番茄钟',
              () => _showIntervalDialog(context),
            ),
          ]),
          const SizedBox(height: 24),
          
          // 通知设置
          _buildSectionTitle('通知设置'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSwitchItem(
              '计时结束提醒',
              '当番茄钟完成时发送通知',
              true,
              (value) {},
            ),
            _buildDivider(),
            _buildSwitchItem(
              '休息结束提醒',
              '当休息时间结束时发送通知',
              true,
              (value) {},
            ),
            _buildDivider(),
            _buildSwitchItem(
              '自动开始休息',
              '专注结束后自动开始休息',
              false,
              (value) {},
            ),
          ]),
          const SizedBox(height: 24),
          
          // 音效设置
          _buildSectionTitle('音效'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSwitchItem(
              '计时音效',
              '计时器开始/结束时播放声音',
              true,
              (value) {},
            ),
            _buildDivider(),
            _buildSwitchItem(
              '振动提醒',
              '计时器结束时振动',
              true,
              (value) {},
            ),
          ]),
          const SizedBox(height: 24),
          
          // 外观设置
          _buildSectionTitle('外观'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingItem(
              '主题',
              '深色',
              '💡',
              () => _showThemeDialog(context),
            ),
            _buildDivider(),
            _buildSwitchItem(
              '跟随系统主题',
              '自动匹配系统深色/浅色模式',
              true,
              (value) {},
            ),
          ]),
          const SizedBox(height: 24),
          
          // 数据管理
          _buildSectionTitle('数据管理'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildActionItem(
              '导出数据',
              '将专注记录导出为CSV文件',
              Icons.download,
              () {},
            ),
            _buildDivider(),
            _buildActionItem(
              '同步数据',
              '云端同步专注记录',
              Icons.cloud_sync,
              () {},
            ),
            _buildDivider(),
            _buildActionItem(
              '清除数据',
              '删除所有本地数据',
              Icons.delete_forever,
              () => _showClearDataDialog(context),
            ),
          ]),
          const SizedBox(height: 24),
          
          // 关于
          _buildSectionTitle('关于'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildInfoItem('版本', '1.0.0'),
            _buildDivider(),
            _buildInfoItem('开发者', '个人开发者'),
            _buildDivider(),
            GestureDetector(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '用户协议',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            _buildDivider(),
            GestureDetector(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '隐私政策',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String value,
    String unit,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value $unit',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppTheme.surfaceColor,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  void _showDurationDialog(
    BuildContext context,
    String title,
    int defaultValue,
    ValueChanged<int> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            '设置$title',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: defaultValue.toDouble(),
                min: 1,
                max: 90,
                divisions: 89,
                onChanged: (value) {
                  defaultValue = value.toInt();
                  (context as Element).markNeedsBuild();
                },
                activeColor: AppTheme.primaryColor,
              ),
              Text(
                '$defaultValue 分钟',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                onChanged(defaultValue);
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showIntervalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        int value = 4;
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            '设置长休息间隔',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: value.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                onChanged: (v) => value = v.toInt(),
                activeColor: AppTheme.primaryColor,
              ),
              Text(
                '每 $value 个番茄钟',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            '选择主题',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption('深色主题', '🌙', true),
              const SizedBox(height: 8),
              _buildThemeOption('浅色主题', '☀️', false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(String name, String emoji, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            '确认清除数据？',
            style: TextStyle(color: AppTheme.error),
          ),
          content: const Text(
            '此操作不可逆，所有专注记录和设置将被删除。',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              onPressed: () {
                Navigator.pop(context);
                // TODO: 实现清除数据
              },
              child: const Text('确认清除'),
            ),
          ],
        );
      },
    );
  }
}
