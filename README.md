# WordDict (iOS 单词听写 App)

这是一个极简的 iOS 单词听写工具，支持导入 Markdown 文件作为单词本，并通过手势进行交互。

## 功能特性

*   **Markdown 导入**: 支持导入格式为 `单词[音标]释义` 的 .md 文件。
*   **听写模式**: 默认只播放发音，不显示单词。
*   **手势控制**:
    *   ⬅️ **左滑**: 下一个单词 (自动发音)
    *   ➡️ **右滑**: 上一个单词
    *   ⬆️ **上滑**: 重播当前发音
    *   ⬇️ **下滑**: 显示单词拼写、音标和解释
*   **随机/顺序**: 支持一键切换顺序或随机播放模式。

## 快速开始

本项目包含生成好的 Swift 源代码。请手动创建一个 Xcode 项目并导入源码。

### 1. 文件结构
源码位于 `Source/` 目录下：
*   `WordModels.swift`: 定义单词数据结构及解析器。
*   `DictationViewModel.swift`: 负责业务逻辑（切换单词、播放声音、状态管理）。
*   `TTSManager.swift`: 封装 iOS 系统语音合成 (Text-to-Speech)。
*   `CardView.swift`: 单词卡片 UI 组件。
*   `ContentView.swift`: 主界面，包含手势识别逻辑。

### 2. 单词本格式
请准备一个 `.md` 或 `.txt` 文件，每行一个单词，格式如下：
```text
word[phonetic]meaning
```
示例：
```text
boy[bɔ i]n. 男孩
apple[ˈæp.l̩]n. 苹果
computer[kəmˈpjuː.tər]n. 计算机
```

### 3. 开发环境
*   Xcode 14.0+
*   iOS 16.0+ (SwiftUI)

## 验证脚本
运行以下命令可测试 Markdown 解析逻辑是否正常：
```bash
swift test_parser.swift
```
