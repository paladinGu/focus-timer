# 🏗️ GitHub Actions 云端打包指南

## 方法一：直接使用 GitHub Actions（推荐）

### 步骤 1：上传项目到 GitHub

```bash
# 在项目目录下执行
cd /root/.openclaw/workspace/focus-timer

# 初始化 Git 仓库
git init
git add .
git commit -m "Initial commit: Focus Timer App"

# 创建 GitHub 仓库（需要在网页上创建）
# 然后添加远程仓库并推送
git remote add origin https://github.com/你的用户名/focus-timer.git
git branch -M main
git push -u origin main
```

### 步骤 2：触发构建

推送代码后，GitHub 会自动：
1. ✅ 安装 Flutter 环境
2. ✅ 获取依赖
3. ✅ 编译 Debug APK
4. ✅ 编译 Release APK
5. 📦 在 Actions 页面下载 APK 文件

### 步骤 3：下载 APK

1. 打开 https://github.com/你的用户名/focus-timer/actions
2. 点击最新的 workflow run
3. 在 "Artifacts" 部分下载：
   - `focus-timer-debug.apk` - 测试版
   - `focus-timer-release.apk` - 正式版

---

## 方法二：手动触发构建

1. 打开 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 选择 **Build Android APK** workflow
4. 点击 **Run workflow**
5. 选择分支（main）并运行

---

## 📱 APK 说明

| 版本 | 用途 | 大小 |
|------|------|------|
| Debug | 测试用，可直接安装 | ~20-30MB |
| Release | 正式发布，需要签名 | ~15-25MB |

---

## ⚠️ 注意事项

1. **首次构建**需要 3-5 分钟（下载 Flutter SDK）
2. **后续构建**只需 1-2 分钟
3. APKs 保留 7-30 天，记得及时下载
4. **Release 版**目前是未签名版本

---

## 🔐 发布签名（可选）

如果要给 Release APK 签名，创建 `android/key.properties`：

```properties
storePassword=你的密码
keyPassword=你的密码
keyAlias=key
storeFile=keystore路径
```

然后修改 `android/app/build.gradle` 添加签名配置。

---

## 📊 GitHub Actions 资源

- **免费额度**：每月 2000 分钟
- **并行任务**：最多 20 个
- **足够**：编译几十次没问题

---

## 🚀 快速链接

- [GitHub Actions](https://github.com/features/actions)
- [Workflow 语法](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
