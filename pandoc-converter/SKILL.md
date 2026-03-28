---
name: pandoc-converter
description: >-
  使用 Pandoc 进行文档格式转换：Markdown、DOCX、PDF、HTML、EPUB、LaTeX、reStructuredText 等 40+ 格式互转。
  当用户需要转换文档格式、生成 PDF/Word/HTML 文档、批量处理文档、或提到 pandoc 时使用。
  触发词：pandoc、文档转换、格式转换、docx转markdown、markdown转pdf、文档导出。
---

# Pandoc 文档格式转换

Pandoc 是通用文档格式转换器，支持 40+ 格式互转。本 skill 自带便携安装能力，无需用户手动安装。

## 环境准备（每次使用前必须执行）

**此步骤为强制前置步骤，任何 pandoc 转换操作前都必须先完成。**

确定本 SKILL.md 所在目录（记为 `$SKILL_DIR`），然后执行对应平台的安装脚本：

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File "$SKILL_DIR/scripts/ensure-pandoc.ps1"
```

**Linux / macOS (Bash):**
```bash
bash "$SKILL_DIR/scripts/ensure-pandoc.sh"
```

脚本会：
1. 检查 `$SKILL_DIR/tools/pandoc/` 下是否已有 pandoc 二进制
2. 若不存在，自动从 GitHub Releases 下载最新版并解压到该目录
3. 输出 `PANDOC_PATH=<完整路径>` —— **捕获此路径，后续所有命令均使用它替代 `pandoc`**

示例：若脚本输出 `PANDOC_PATH=C:\Users\admin\.cursor\skills\pandoc-converter\tools\pandoc\pandoc.exe`，
则后续执行 `C:\Users\admin\.cursor\skills\pandoc-converter\tools\pandoc\pandoc.exe input.md -o output.docx`。

> **重要**：下文所有示例中的 `pandoc` 命令均为简写，实际执行时必须替换为上面获取的 `$PANDOC_PATH` 完整路径。

### PDF 输出额外依赖

PDF 输出还需要 LaTeX 引擎（pandoc 本身不含）：
- 推荐安装 [TeX Live](https://tug.org/texlive/) 或 [MiKTeX](https://miktex.org/)
- 中文 PDF 必须使用 `xelatex` 或 `lualatex` 引擎
- 若无 LaTeX，可改用 `--pdf-engine=wkhtmltopdf` 或 `--pdf-engine=weasyprint`（需单独安装）

## 基本语法

```bash
pandoc [输入文件...] -o 输出文件 [选项]
```

核心参数：
| 参数 | 说明 |
|------|------|
| `-f FORMAT` / `--from` | 指定输入格式（通常可自动推断） |
| `-t FORMAT` / `--to` | 指定输出格式（通常可自动推断） |
| `-o FILE` / `--output` | 输出文件路径 |
| `-s` / `--standalone` | 生成完整独立文档（含 header/footer） |
| `--toc` | 生成目录 |
| `--toc-depth=N` | 目录深度（默认 3） |
| `-N` / `--number-sections` | 章节自动编号 |
| `--template=FILE` | 使用自定义模板 |
| `--reference-doc=FILE` | 使用参考文档样式（docx/odt/pptx） |
| `--pdf-engine=ENGINE` | PDF 引擎（xelatex/lualatex/wkhtmltopdf/weasyprint） |
| `--metadata KEY=VAL` | 设置元数据 |
| `-V KEY=VAL` / `--variable` | 设置模板变量 |
| `--bibliography=FILE` | 指定参考文献库 |
| `--citeproc` | 启用引文处理 |
| `--csl=FILE` | 指定引文样式 |
| `--extract-media=DIR` | 提取媒体文件到指定目录 |
| `--wrap=none` | 不自动换行（保持长行） |

## 常用转换速查

### Markdown → 其他格式

```bash
# Markdown → Word docx
pandoc input.md -o output.docx

# Markdown → Word（使用自定义样式模板）
pandoc input.md --reference-doc=template.docx -o output.docx

# Markdown → PDF（中文支持）
pandoc input.md --pdf-engine=xelatex -V CJKmainfont="SimSun" -o output.pdf

# Markdown → PDF（带目录、页边距、字体设置）
pandoc input.md --pdf-engine=xelatex -V CJKmainfont="SimSun" -V geometry=margin=1in -V fontsize=12pt --toc -N -o output.pdf

# Markdown → HTML（独立完整页面）
pandoc -s input.md -o output.html

# Markdown → HTML（带目录和 CSS）
pandoc -s --toc -c style.css input.md -o output.html

# Markdown → EPUB 电子书
pandoc input.md --metadata title="书名" -o output.epub

# Markdown → LaTeX
pandoc -s input.md -o output.tex

# Markdown → reveal.js 幻灯片
pandoc -s -t revealjs -i slides.md -o slides.html

# Markdown → Beamer PDF 幻灯片
pandoc -t beamer slides.md --pdf-engine=xelatex -o slides.pdf

# Markdown → Jupyter Notebook
pandoc input.md -o output.ipynb
```

### 其他格式 → Markdown

```bash
# Word docx → Markdown（提取图片）
pandoc input.docx -t markdown --extract-media=./media -o output.md

# Word docx → GFM Markdown
pandoc input.docx -t gfm --extract-media=./media --wrap=none -o output.md

# HTML → Markdown
pandoc -f html -t markdown -s input.html -o output.md

# 网页 URL → Markdown
pandoc -s -r html https://example.com -o output.md

# LaTeX → Markdown
pandoc -s input.tex -o output.md

# EPUB → Markdown
pandoc input.epub -t markdown -o output.md

# reStructuredText → Markdown
pandoc -f rst -t markdown input.rst -o output.md
```

### 格式间互转

```bash
# docx → PDF
pandoc input.docx --pdf-engine=xelatex -V CJKmainfont="SimSun" -o output.pdf

# docx → HTML
pandoc input.docx -s -o output.html

# HTML → docx
pandoc input.html -o output.docx

# HTML → PDF
pandoc input.html --pdf-engine=xelatex -o output.pdf

# LaTeX → docx
pandoc input.tex -o output.docx

# DocBook XML → Markdown
pandoc -f docbook -t markdown -s input.xml -o output.md

# BibTeX → CSL JSON
pandoc biblio.bib -t csljson -o biblio.json

# ODT → docx
pandoc input.odt -o output.docx
```

## 中文文档处理要点

生成中文 PDF 时**必须**指定 CJK 字体，否则中文不显示：

```bash
pandoc input.md --pdf-engine=xelatex \
  -V CJKmainfont="SimSun" \
  -V CJKsansfont="SimHei" \
  -V CJKmonofont="FangSong" \
  -o output.pdf
```

Windows 常用中文字体名：
| 字体 | 名称 |
|------|------|
| 宋体 | SimSun |
| 黑体 | SimHei |
| 仿宋 | FangSong |
| 楷体 | KaiTi |
| 微软雅黑 | Microsoft YaHei |

macOS/Linux 使用 `Noto Sans CJK SC` 或 `Noto Serif CJK SC`。

查看系统可用中文字体：
```bash
# Windows PowerShell
[System.Drawing.FontFamily]::Families | Where-Object { $_.Name -match 'sim|hei|song|kai|yahei|noto.*cjk' }

# Linux
fc-list :lang=zh

# macOS
fc-list :lang=zh
```

## 高级功能

### 自定义 Word 样式模板

1. 生成默认参考文档：
```bash
pandoc -o custom-reference.docx --print-default-data-file reference.docx
```
2. 用 Word 打开 `custom-reference.docx`，修改样式（标题、正文、代码块等）
3. 转换时使用：
```bash
pandoc input.md --reference-doc=custom-reference.docx -o output.docx
```

### YAML 元数据块

在 Markdown 文件头部添加元数据：

```yaml
---
title: "文档标题"
author: "作者"
date: "2026-03-29"
lang: zh-CN
toc: true
toc-depth: 3
number-sections: true
geometry: margin=1in
fontsize: 12pt
CJKmainfont: "SimSun"
---
```

这样转换时无需在命令行重复指定这些参数。

### 多文件合并

```bash
pandoc ch01.md ch02.md ch03.md -o book.docx
pandoc ch*.md --toc -N -o book.pdf --pdf-engine=xelatex -V CJKmainfont="SimSun"
```

### Lua 过滤器

```bash
pandoc input.md --lua-filter=filter.lua -o output.docx
```

### 引文和参考文献

```bash
pandoc paper.md --citeproc --bibliography=refs.bib --csl=ieee.csl -o paper.pdf --pdf-engine=xelatex
```

## 批量转换

```bash
# Bash: 目录下所有 md → docx
for f in *.md; do pandoc "$f" -o "${f%.md}.docx"; done

# Bash: 所有 md → PDF（中文）
for f in *.md; do pandoc "$f" --pdf-engine=xelatex -V CJKmainfont="SimSun" -o "${f%.md}.pdf"; done

# PowerShell: 所有 md → docx
Get-ChildItem *.md | ForEach-Object { pandoc $_.FullName -o ($_.BaseName + ".docx") }

# PowerShell: 所有 md → PDF（中文）
Get-ChildItem *.md | ForEach-Object { pandoc $_.FullName --pdf-engine=xelatex -V CJKmainfont="SimSun" -o ($_.BaseName + ".pdf") }
```

## 常见问题排查

| 问题 | 原因 | 解决 |
|------|------|------|
| 中文 PDF 空白/乱码 | 未指定 CJK 字体 | 添加 `-V CJKmainfont="SimSun"` |
| PDF 生成失败 | 未安装 LaTeX | 安装 TeX Live / MiKTeX |
| 图片丢失 | docx/epub 含内嵌图片 | 添加 `--extract-media=./media` |
| 表格样式丢失 | Pandoc 简化了复杂表格 | 使用 `--reference-doc` 自定义样式 |
| HTML 缺少样式 | 未使用独立模式 | 添加 `-s` 和 `-c style.css` |
| 长行被截断 | 自动折行 | 添加 `--wrap=none` |
| 编码错误 | 输入文件非 UTF-8 | 先转换为 UTF-8 编码 |

## 更多资源

- 完整格式列表和高级选项，参见 [reference.md](reference.md)
- 实战示例和工作流，参见 [examples.md](examples.md)
- 官方手册: https://pandoc.org/MANUAL
- 在线试用: https://pandoc.org/app
