# Miko 动效交付

在线预览动效、重播和调试交互，查看及复制 SwiftUI 参数。

## 访问地址

- GitHub Pages：https://pointediu.github.io/miko-motion-handoff/
- 原 Sites 地址：https://miko-reward-motion.dayinwater.chatgpt.site

## 更新与发布

`out/` 是完整网站源文件，包含首页、独立预览、素材和 SwiftUI 参数。无需安装依赖或构建框架。

修改后提交并推送到 `main`，GitHub Actions 会自动发布 `out/`。在仓库的 Actions 页面查看发布结果，发布成功后刷新同一个网站链接即可。

```sh
git add out README.md .github
git commit -m "Update motion previews"
git push origin main
```

仓库 Settings → Pages 的 Source 应为 **GitHub Actions**。

## 与当前本地单文件版本同步

本机 `dist/` 保留离线单文件版本，因体积较大未纳入 Git。继续通过 Codex 修改本机动效时，先更新离线版，再执行：

```sh
python3 build-web.py
git add -A
git commit -m "Update motion previews"
git push origin main
```

从 GitHub 克隆的新环境可直接编辑 `out/`，不需要 `dist/`。修改独立预览时，同步首页相应的参数描述；V1–V5 的独立页及参数也保存在 `out/animations/`。

GitHub 发布只更新 GitHub Pages；原 Sites 链接保留上次发布的内容，需单独发布才会同步。
