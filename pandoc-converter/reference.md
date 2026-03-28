# Pandoc 格式参考

## 支持的输入格式

| 格式标识 | 说明 | 常见扩展名 |
|----------|------|-----------|
| `markdown` | Pandoc's Markdown（默认，支持扩展） | .md, .markdown |
| `gfm` | GitHub Flavored Markdown | .md |
| `commonmark` | CommonMark Markdown | .md |
| `commonmark_x` | CommonMark + 扩展 | .md |
| `docx` | Microsoft Word | .docx |
| `odt` | OpenDocument Text | .odt |
| `html` | HTML | .html, .htm |
| `latex` | LaTeX | .tex |
| `epub` | EPUB 电子书 | .epub |
| `rst` | reStructuredText | .rst |
| `org` | Emacs Org mode | .org |
| `mediawiki` | MediaWiki 标记 | |
| `docbook` | DocBook XML | .xml |
| `csv` | CSV 表格 | .csv |
| `tsv` | TSV 表格 | .tsv |
| `json` | Pandoc JSON AST | .json |
| `bibtex` | BibTeX 参考文献 | .bib |
| `biblatex` | BibLaTeX 参考文献 | .bib |
| `jats` | JATS XML | .xml |
| `rtf` | Rich Text Format | .rtf |
| `ipynb` | Jupyter Notebook | .ipynb |
| `pptx` | PowerPoint | .pptx |
| `xlsx` | Excel 电子表格 | .xlsx |
| `textile` | Textile | .textile |
| `twiki` | TWiki | |
| `tikiwiki` | TikiWiki | |
| `dokuwiki` | DokuWiki | |
| `jira` | Jira/Confluence 标记 | |
| `typst` | Typst | .typ |
| `asciidoc` | AsciiDoc | .adoc |
| `man` | roff man 页 | |
| `fb2` | FictionBook2 电子书 | .fb2 |
| `opml` | OPML | .opml |

## 支持的输出格式

除上述大部分格式外，还额外支持：

| 格式标识 | 说明 |
|----------|------|
| `pdf` | PDF（需 LaTeX/wkhtmltopdf/weasyprint） |
| `beamer` | LaTeX Beamer 幻灯片 |
| `revealjs` | reveal.js HTML 幻灯片 |
| `slidy` | Slidy HTML 幻灯片 |
| `dzslides` | DZSlides 幻灯片 |
| `s5` | S5 幻灯片 |
| `context` | ConTeXt |
| `texinfo` | GNU Texinfo |
| `plain` | 纯文本 |
| `ansi` | ANSI 终端彩色文本 |
| `icml` | InDesign ICML |
| `chunkedhtml` | 分块 HTML（多页） |
| `epub2` | EPUB v2 |
| `epub3` | EPUB v3 |
| `ms` | roff ms |
| `tei` | TEI Simple |
| `markua` | Markua |
| `xwiki` | XWiki |
| `zimwiki` | ZimWiki |
| `bbcode` | BBCode |

## PDF 引擎选项

| 引擎 | 安装方式 | 适用场景 |
|------|---------|---------|
| `xelatex` | TeX Live / MiKTeX | 中文/多语言 PDF（推荐） |
| `lualatex` | TeX Live / MiKTeX | 中文/多语言 PDF，Lua 扩展 |
| `pdflatex` | TeX Live / MiKTeX | 纯英文/西欧语言 |
| `wkhtmltopdf` | 独立安装 | 基于 HTML 渲染的 PDF |
| `weasyprint` | pip install weasyprint | 基于 CSS 的 PDF |
| `prince` | 商业软件 | 高质量排版 |
| `typst` | cargo/brew 安装 | 现代排版引擎 |

## Markdown 扩展

Pandoc Markdown 默认启用大量扩展，可通过 `+ext` / `-ext` 控制：

```bash
# 禁用智能标点
pandoc -f markdown-smart input.md -o output.html

# 使用 GFM + 脚注
pandoc -f gfm+footnotes input.md -o output.html
```

常用扩展：
| 扩展 | 说明 |
|------|------|
| `pipe_tables` | 管道表格 |
| `footnotes` | 脚注 |
| `yaml_metadata_block` | YAML 元数据 |
| `fenced_code_blocks` | 围栏代码块 |
| `fenced_code_attributes` | 代码块属性 |
| `task_lists` | 任务列表 |
| `strikeout` | 删除线 |
| `superscript` / `subscript` | 上标/下标 |
| `tex_math_dollars` | LaTeX 数学公式 |
| `raw_html` / `raw_tex` | 原始 HTML/TeX |
| `implicit_figures` | 图片自动变成 figure |
| `smart` | 智能标点（弯引号、破折号） |

## 模板系统

查看默认模板：
```bash
pandoc -D html     # HTML 默认模板
pandoc -D latex    # LaTeX 默认模板
pandoc -D docx     # docx 不使用文本模板，用 reference-doc
```

模板变量通过 `-V key=value` 或 YAML 元数据设置。

### LaTeX/PDF 常用模板变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `geometry` | 页面几何（页边距等） | `margin=1in` |
| `fontsize` | 正文字号 | `12pt` |
| `mainfont` | 正文字体（xelatex/lualatex） | `"Times New Roman"` |
| `sansfont` | 无衬线字体 | `"Arial"` |
| `monofont` | 等宽字体 | `"Courier New"` |
| `CJKmainfont` | 中日韩正文字体 | `"SimSun"` |
| `CJKsansfont` | 中日韩无衬线字体 | `"SimHei"` |
| `CJKmonofont` | 中日韩等宽字体 | `"FangSong"` |
| `documentclass` | 文档类 | `article`, `report`, `book` |
| `classoption` | 文档类选项 | `twocolumn` |
| `linestretch` | 行距 | `1.5` |
| `colorlinks` | 彩色链接 | `true` |
| `linkcolor` | 链接颜色 | `blue` |
| `header-includes` | 自定义 LaTeX 头部 | |

### HTML 常用模板变量

| 变量 | 说明 |
|------|------|
| `css` | CSS 文件路径（也可用 `-c`） |
| `include-before` | body 开头插入内容 |
| `include-after` | body 末尾插入内容 |
| `header-includes` | head 中插入内容 |

## 过滤器

### Lua 过滤器（推荐，无需额外依赖）

```bash
pandoc input.md --lua-filter=filter.lua -o output.docx
```

示例 filter.lua —— 将所有一级标题改为二级：
```lua
function Header(el)
  if el.level == 1 then
    el.level = 2
  end
  return el
end
```

### JSON 过滤器

```bash
pandoc input.md --filter=my-filter.py -o output.html
```

## 引文处理

需要 `--citeproc` 参数和参考文献文件：

```bash
pandoc paper.md --citeproc --bibliography=refs.bib -o paper.pdf --pdf-engine=xelatex
```

支持的参考文献格式：BibTeX (.bib)、BibLaTeX (.bib)、CSL JSON (.json)、CSL YAML (.yaml)

CSL 样式文件从 https://github.com/citation-style-language/styles 获取。
