# Pandoc 实战示例

## 场景 1：技术文档 Markdown → 精美 Word

将项目文档导出为专业排版的 Word 文件。

```bash
# 第一步：生成参考文档模板
pandoc -o custom-reference.docx --print-default-data-file reference.docx

# 第二步：用 Word 打开 custom-reference.docx，修改样式后保存

# 第三步：使用模板转换
pandoc README.md \
  --reference-doc=custom-reference.docx \
  --toc --toc-depth=3 \
  -N \
  -o README.docx
```

## 场景 2：Markdown → 中文 PDF 报告

```bash
pandoc report.md \
  --pdf-engine=xelatex \
  -V CJKmainfont="SimSun" \
  -V CJKsansfont="SimHei" \
  -V geometry="margin=2.5cm" \
  -V fontsize=12pt \
  -V linestretch=1.5 \
  -V colorlinks=true \
  --toc --toc-depth=2 \
  -N \
  -o report.pdf
```

或者在 Markdown 头部使用 YAML 元数据（推荐，更便携）：

```markdown
---
title: "项目技术报告"
author: "团队名称"
date: "2026-03-29"
lang: zh-CN
CJKmainfont: "SimSun"
CJKsansfont: "SimHei"
geometry: margin=2.5cm
fontsize: 12pt
linestretch: 1.5
toc: true
toc-depth: 2
number-sections: true
colorlinks: true
---

# 第一章 概述

正文内容...
```

```bash
pandoc report.md --pdf-engine=xelatex -o report.pdf
```

## 场景 3：Word 文档 → Markdown（保留图片）

```bash
pandoc input.docx \
  -t gfm \
  --extract-media=./images \
  --wrap=none \
  -o output.md
```

转换后 `output.md` 中的图片引用指向 `./images/` 目录。

## 场景 4：多个 Markdown 文件 → 一本电子书

```bash
pandoc metadata.yaml \
  ch01-introduction.md \
  ch02-design.md \
  ch03-implementation.md \
  --toc --toc-depth=2 \
  -N \
  --epub-cover-image=cover.png \
  -o book.epub
```

metadata.yaml：
```yaml
---
title: "我的技术书"
author: "作者"
lang: zh-CN
rights: "Copyright 2026"
---
```

## 场景 5：Markdown → reveal.js 演示文稿

```bash
pandoc -s -t revealjs \
  --slide-level=2 \
  -V theme=moon \
  -V transition=slide \
  --mathjax \
  -i slides.md \
  -o slides.html
```

Markdown 幻灯片格式（用 `---` 或标题层级分隔）：
```markdown
---
title: "演示标题"
author: "演讲者"
---

# 第一部分

## 幻灯片 1

- 要点 A
- 要点 B

## 幻灯片 2

![示意图](image.png)

# 第二部分

## 幻灯片 3

$$E = mc^2$$
```

## 场景 6：批量转换项目中所有 Markdown

PowerShell：
```powershell
# 所有 md → docx
Get-ChildItem -Recurse -Filter "*.md" | ForEach-Object {
    $out = $_.FullName -replace '\.md$', '.docx'
    pandoc $_.FullName -o $out
    Write-Host "Converted: $($_.Name) -> $([System.IO.Path]::GetFileName($out))"
}

# 所有 md → PDF（中文）
Get-ChildItem -Recurse -Filter "*.md" | ForEach-Object {
    $out = $_.FullName -replace '\.md$', '.pdf'
    pandoc $_.FullName --pdf-engine=xelatex -V CJKmainfont="SimSun" -o $out
    Write-Host "Converted: $($_.Name) -> $([System.IO.Path]::GetFileName($out))"
}
```

Bash：
```bash
find . -name "*.md" -exec sh -c 'pandoc "$1" -o "${1%.md}.docx"' _ {} \;
```

## 场景 7：网页抓取并转为 Markdown

```bash
pandoc -s -r html https://pandoc.org/MANUAL.html -t gfm --wrap=none -o pandoc-manual.md
```

## 场景 8：使用 Lua 过滤器自定义转换

将所有代码块添加行号标记：

filter-line-numbers.lua：
```lua
function CodeBlock(el)
  el.classes:insert("numberLines")
  return el
end
```

```bash
pandoc input.md --lua-filter=filter-line-numbers.lua -o output.html
```

将图片路径从相对路径改为绝对路径：

filter-abs-images.lua：
```lua
function Image(el)
  if not el.src:match("^https?://") then
    el.src = "/assets/images/" .. el.src
  end
  return el
end
```

## 场景 9：学术论文（含引文和参考文献）

paper.md：
```markdown
---
title: "论文标题"
author: "作者"
bibliography: refs.bib
csl: china-national-standard-gb-t-7714-2015-author-date.csl
---

正如 @smith2024 所述，这一方法在实验中表现优异。
多项研究 [@wang2023; @li2024] 证实了该结论。

# 参考文献
```

```bash
pandoc paper.md --citeproc --pdf-engine=xelatex -V CJKmainfont="SimSun" -o paper.pdf
```

## 场景 10：docx → PDF（保留原样式）

```bash
# 先转为 HTML 中间格式再到 PDF（保真度较高）
pandoc input.docx -t html5 -o temp.html
pandoc temp.html --pdf-engine=weasyprint -o output.pdf

# 或直接转（可能丢失部分样式）
pandoc input.docx --pdf-engine=xelatex -V CJKmainfont="SimSun" -o output.pdf
```
