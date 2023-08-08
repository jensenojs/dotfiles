这个README希望能解决两个问题：

1. 自查
2. 如果你也有兴趣使用这个配置文件的话，我希望它能帮到你

## basic

## plugin

下面摘选了一些我喜欢的插件，它们大多都是从blog上则去的，相关的link我放在了ref中：可以去看看[Awesome Neovim](https://github.com/rockerBOO/awesome-neovim)这个仓库。


### before we start ：[which key](https://github.com/folke/which-key.nvim)


### beautify

这里介绍一些让`neovim`能看起来不逊于`ide`的插件，一般都是配置好就可以用了，不用再去管它。


#### [Scope.nvim](https://github.com/tiagovla/scope.nvim)

首先我们要捋一下`buffer/window/tab`三者的联系和区别。

-   `Buffer` 是 `vim` 打开文件的时候创建的一个缓冲区，用来存储打开的文件 。 使用 `vim` 每打开一个文件就会创建一个 `Buffer` 。
-   窗口是用来展示 Buffer 的信息的
-   Tab 可以想象成浏览器中的标签页，不同之处是 vim 中的 一个Tab 可以有很多个窗口，每个窗口用来展示文件的内容信息。

![buffer_window_tab](./img/buffer_window_tab.png)

为什么要提这个呢。。。因为`buffer`这个逻辑在编辑文件的时候不是很自然，buffer 可以绑定在窗口上, 即使窗口关闭，缓冲区依然存在，然后会有这个`duplicated`的问题，

![duplicated-tab](./img/duplicated-tab.png)

但是另一方面，这种方式又能提供更多的自由——这里有一些[讨论](https://www.reddit.com/r/neovim/comments/11itoab/how_do_you_manage_tabs_and_split_panes_in_vim/)，你也许想要看看。我在阅读之后放弃了想要把`vim`的这种模式利用`scope.nvim`调整过来的念头~~还有一个理由是我scope.nvim怎么搞都不太对的样子~~



#### [nvim-lastplace](https://github.com/ethanholz/nvim-lastplace)

-   自动记忆当前文件位置，在下次打开时定位到上次位置。

#### [gruvbox](https://github.com/ellisonleao/gruvbox.nvim)

-   好看捏

#### 基于[tree-sitter](https://github.com/nvim-treesitter/nvim-treesitter)的插件

`tree-sitter`可以基于AST对代码语法进行解析，这样的高亮做出来很不错。

##### [nvim-ts-rainbow2](https://github.com/HiPhish/nvim-ts-rainbow2)

-   将配对的括号进行彩色的标注，方便辨认。

##### [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)

-   它可以将当前函数的函数头固定在neovim界面的前几行，让你知道当前在编辑的是什么类、函数或方法。

### curosr

#### [flash](https://github.com/folke/flash.nvim)

结合了[easymotion](https://github.com/easymotion/vim-easymotion)和[clvever-f](https://github.com/rhysd/clever-f.vim)的功能, 还有Treesitte集成，功能也十分强大

-   `s`：和`easymotion`类似，后面跟上两个字母实现快速跳转，但是比`easymotion`还能少按一次。
-   `S`：


#### [nvim-surround](https://github.com/kylechui/nvim-surround)

这个似乎比`vim-surround`好用一些，记住三个就行：

-   `add`：`ys{motion}{char}`
-   `delete`：`ds{motion}{char}`
-   `change`：`cs{target}{replacement}`

For the following examples, `*` will denote the cursor position:

```
    Old text                    Command         New text
--------------------------------------------------------------------------------
    surr*ound_words             ysiw)           (surround_words)
    *make strings               ys$"            "make strings"
    [delete ar*ound me!]        ds]             delete around me!
    remove <b>HTML t*ags</b>    dst             remove HTML tags
    'change quot*es'            cs'"            "change quotes"
    <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
    delete(functi*on calls)     dsf             function calls
```

#### [vim-matchup](https://github.com/andymass/vim-matchup)

在vim中，按下%会跳转到当前光标所在位置的配对括号（如圆括号、方括号、花括号）的另一半括号位置。这个功能在编辑代码时非常有用，可以快速定位到配对的括号上，方便代码的阅读和编辑。

这个插件，可以基于`treesitter`扩展`%`键能力，在配置里面也已经设置好了，其他还有一些快捷键，但是我们可以不用管了，`z%` 可以go inside，但是我们也不见得需要它来跳转。


#### [tabout.nvim](https://github.com/abecodes/tabout.nvim)

可以在Insert模式下，按`<Tab>`可以跳出括号 —— 这个东西默认跟`coc-nvim`的自动补齐会有冲突，但是在coc-nvim.lua中应该已经配置好了。


#### [nvim-various-textobjs](https://github.com/chrisgrieser/nvim-various-textobjs)

为neovim新增很多textobjects，它们可以丰富你的快捷键选中、复制、修改等操作的体验。

使用方式：快捷键使用（以选中功能"v"来举例，可以替换为"c"（删除并修改）、"d"（删除）、"y"复制等）（`i`可以替换为`a`，`i`表示"inner"，`a`表示"outer"，如`va}`会选中包括`}`本身的内容，而`vi}`则不会）

-   `viS`：选中当前光标下的子word（如`VimEnter`，我们使用`viw`会选中整个`VimEnter`，但`viS`只会选中`Enter`或`Vim`）
-   `vii`：选中当前相同缩进的所有行
-   `vR`：选中当前相同缩进往后剩余的行
-   `v%`：选中当前光标下对应的括号结束位置
-   `vr`：选中剩余的段落
-   `vgG`：选中整个文件
-   `v_`：选中整行有字符的部分（除去空白字符）
-   `viv`：选中key-value的value部分
-   `vik`：选中key-value的key部分
-   `vL`：选中URL
-   `vin`：选中数字部分
-   `v!`：选中诊断部分（需要LSP）
-   `vil`：选中markdown的链接
-   `viC`：选中markdown的代码块部分
-   `vic`：选中css选择器
-   `vi/`：选中javascript的正则表达式pattern
-   `viD`：选中双中括号内容`[[]]`

#### [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)

简介：基于nvim-treesitter的textobjects，可以帮你选中class、function等语法内容

使用方式：快捷键使用，类似于nvim-various-textobjs（以选中模式`v`举例）

1.  选择

-   `vaf`：选中当前函数
-   `vac`：选中当前类内容
-   `vas`：选中当前scope
-   `vad`：选中当前条件（if..else）

1.  跳转

-   `]m`：跳到下一个函数的开始处
-   `]]`：跳到下一个类的开始处
-   `]s`：跳到下一个scope的开始处
-   `]z`：跳到下一个fold的开始处
-   `]M`：跳到下一个函数的结尾处
-   `][`：跳到下一个类的结尾处
-   `[m`：跳到上一个函数的开始处
-   `[[`：跳到上一个类的开始处
-   `[M`：跳到上一个函数的结尾处
-   `[]`：跳到上一个类的结尾处
-   `]d`：跳到下一个条件
-   `[d`：跳到上一个条件

#### [nvim-treesitter-textsubjects](https://github.com/RRethy/nvim-treesitter-textsubjects)

根据光标位置自动决定要选中什么textobject

使用方式：快捷键使用（以v选中模式举例）

-   `v.`：根据光标位置，智能选择
-   `v,`：选中上一次选中的范围
-   `v;`：选中容器外围
-   `vi;`：选中容器内



### ide

这里介绍一些让`neovim`能用起来不逊于`ide`的插件



#### [coc-nvim](https://github.com/neoclide/coc.nvim)





#### [telescope](https://github.com/nvim-telescope/telescope.nvim)





#### [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)

总得需要一个目录树，它的快捷键也相当多。



#### [lazygit](https://github.com/jesseduffield/lazygit#homebrew)

>   Rant time: You've heard it before, git is *powerful*, but what good is that power when everything is so damn hard to do? Interactive rebasing requires you to edit a goddamn TODO file in your editor? *Are you kidding me?* 

`lazygit`是一个在终端下**符合`vim`直觉**的`git`客户端，使用了`neovim`的插件之后（按下`<leader>G`），即可在`vim`里打开它，而且你完全可以用鼠标/触摸板！

下面结合图片简要地介绍一下它的用法——

![lazygit界面介绍](./img/lazygit界面介绍.png)

对于不同的工作区（文件，分支界面，提交记录，存储就是`stash`——也就是隐藏的更改）等，可以直接按数字进行对应的跳转（`tab`和`shift+tab`也可以进行工作区之间的快速切换，`h`和`l`也可以）。

“符合`vim`直觉”这个事情会给你带来许多惊喜——`j`和`k`在工作区内进行移动（`h/l`是在工作区间），`/`的搜索当然也可以用，`d`会删除一些东西（具体情况下删除的对象会有点不一样，但都很符合直觉）。`q`退出回去终端，`esc`回到上一个页面，`enter`进入下一级操作。

按下`?`就可以弹出帮助界面，它会贴心地弹出对应工作区下涉及的快捷指令。

![lazygit的帮助界面](./img/lazygit的帮助界面.png)

你（我）已经知道怎么查阅文档了，下面只会记录一些我常用的快捷键。

##### 与远端仓库的交互

-   `p`：更新仓库
-   `P`：推送到仓库
-   `u`：设定链接的远端仓库
    -   之所以需要专门提这一嘴是因为我开发的工作流默认有两个远端仓库`origin`和`upstream`，在没有自定义`lazygit`的命令之前，我偶尔需要设定一下它

##### 工作区操作

-   文件：按下`1`跳转到文件
    -   `<space>`用于将文件加入和移出工作区，`a`用于对所有文件加入/移出
        -   按`tab`可以在`staged`和`unstaged`的页面之间进行切换
        -   可以对某个文件按下`Enter`，然后针对特定的修改按下`<space>`进行行级别的`stage`
        -   在`staged`的页面，可以按下`d`进行行级别的`unstage`
    -   `c`：提交代码
    -   `d`：重置当前文件，`D`重置所有文件（会有更多放弃更改的选项）
    -   `s`：暂存所有文件，`S`暂存选中文件
        -   可以设定个名字
-   分支管理：按下`3`跳转到分支管理
    -   `<space>`：切换分支
    -   `n`：创建新的分支
    -   `d`：删除分支
    -   `r`：rebase分支：把选中的分支合并到当前分支，`m`同理
    -   `g`
-   提交记录：按下`4`跳转到提交记录
    -   `d`：删除提交
    -   `g`：重置到指定提交，它也会显示更多的选项
    -   `r`：改写提交的comment
    -   `A`：把当前的`stage`添加到上一次提交中
    -   `s`：把选中的`commit`和它下面一个`commit`进行合并，`f`（fixup）也能起到类似的效果 —— 这些东西都是`rebase` 的选项

-   `stash`管理：按下`5`跳转到贮藏
    -   `g`：应用并删除（也就是`pop`）

##### 解决冲突

-   上下左右键进行冲突之间的移动，`vim`的快捷键应该也行叭。

-   `<space>`：选中某一种更改，`b`两种更改都想要

##### 其他的操作

-   查看某个文件的历史记录
    -    在`commit`的工作区，~~`<c-f>`可以进行`filter`~~，可以过滤出修改过某个文件的`commits`
    -   得查查这个快捷键现在是什么了

-   `commit`之间的`diff`
    -    在`commit`的工作区，`W`



想要更新手友好的学习资料？可以看看[这个](https://www.bilibili.com/video/BV1gV411k7fC/?spm_id_from=333.1007.top_right_bar_window_history.content.click&vd_source=d15d9e4ac1d8a1510dd3fb4eba690017)。



#### [persistence.nvim](https://github.com/folke/persistence.nvim)

自动保存你的session到文件中，在下次打开相同目录/项目时，你可以手动加载session恢复之前的工作状态。



### 未来

下面是一些只是可能未来有用的插件，但是我现在还用不上，现在收集起来以后就能懒得找了



#### [nvim-spectre](https://github.com/nvim-pack/nvim-spectre)

简介：搜索并替换项目中所有文件/当前文件/当前选中区域的内容

使用方式：快捷键使用



#### [search-replace.nvim](https://github.com/roobert/search-replace.nvim)

简介：受够了手动输入`:%s/xxx/ccc/gcI`吗？这款插件可以使用快捷键一键帮你输入这些内容。 这款插件是spectre插件的补充，你可以用这款插件或者spectre插件来达到全局文件替换的效果。

使用方式：快捷键使用

1.  当前缓冲区：

-   `<leader>rs`：打开选择列表（个人不会用）
-   `<leader>ro`：打开Cmdline，自动帮你键入好了`:%s//gcI`
-   `<leader>rw`：打开Cmdline，自动帮你键入好了当前光标所在的word
-   `<leader>rW`：打开Cmdline，自动帮你键入好了当前光标所在WORD
-   `<leader>re`：...
-   `<leader>rf`：...

1.  所有打开的缓冲区：同上，但是前缀是`<leader>rb`，只要多加一个`b`键即可 具体快捷键见下面的“快捷键配置”

配置：

```
{
    "roobert/search-replace.nvim",
    lazy = true,
    cmd = {
        "SearchReplaceSingleBufferVisualSelection",
        "SearchReplaceSingleBufferOpen",
        "SearchReplaceWithinVisualSelection",
        "SearchReplaceWithinVisualSelectionCWord",
        "SearchReplaceSingleBufferSelections",
        "SearchReplaceSingleBufferCWord",
        "SearchReplaceSingleBufferCWORD",
        "SearchReplaceSingleBufferCExpr",
        "SearchReplaceSingleBufferCFile",
        "SearchReplaceMultiBufferSelections",
        "SearchReplaceMultiBufferOpen",
        "SearchReplaceMultiBufferCWord",
        "SearchReplaceMultiBufferCWORD",
        "SearchReplaceMultiBufferCExpr",
        "SearchReplaceMultiBufferCFile",
    },
    config = function()
        require("search-replace").setup({
            default_replace_single_buffer_options = "gcI",
            default_replace_multi_buffer_options = "egcI",
        })
    end,
}
```



快捷键配置：

```
-- search.replace.nvim config BEGIN
keymap["r"] = {
    name = "SearchReplaceSingleBuffer",
    s = { "<CMD>SearchReplaceSingleBufferSelections<CR>", "SearchReplaceSingleBuffer [s]elction list" },
    o = { "<CMD>SearchReplaceSingleBufferOpen<CR>", "[o]pen" },
    w = { "<CMD>SearchReplaceSingleBufferCWord<CR>", "[w]ord" },
    W = { "<CMD>SearchReplaceSingleBufferCWORD<CR>", "[W]ORD" },
    e = { "<CMD>SearchReplaceSingleBufferCExpr<CR>", "[e]xpr" },
    f = { "<CMD>SearchReplaceSingleBufferCFile<CR>", "[f]ile" },
    b = {
        name = "SearchReplaceMultiBuffer",
        s = { "<CMD>SearchReplaceMultiBufferSelections<CR>", "SearchReplaceMultiBuffer [s]elction list" },
        o = { "<CMD>SearchReplaceMultiBufferOpen<CR>", "[o]pen" },
        w = { "<CMD>SearchReplaceMultiBufferCWord<CR>", "[w]ord" },
        W = { "<CMD>SearchReplaceMultiBufferCWORD<CR>", "[W]ORD" },
        e = { "<CMD>SearchReplaceMultiBufferCExpr<CR>", "[e]xpr" },
        f = { "<CMD>SearchReplaceMultiBufferCFile<CR>", "[f]ile" },
    },
}
lvim.keys.visual_block_mode["<C-r>"] = [[<CMD>SearchReplaceSingleBufferVisualSelection<CR>]]
lvim.keys.visual_block_mode["<C-s>"] = [[<CMD>SearchReplaceWithinVisualSelection<CR>]]
lvim.keys.visual_block_mode["<C-b>"] = [[<CMD>SearchReplaceWithinVisualSelectionCWord<CR>]]
vim.o.inccommand = "split"
-- search.replace.nvim config END
```



#### [nvim-bqf](https://github.com/kevinhwang91/nvim-bqf)

简介：增强你的quickfix窗口

使用方式：配置即可显示增强的quickfix窗口，然后在quickfix窗口内使用对应快捷键操作quickfix



### [nvim-recorder](https://github.com/chrisgrieser/nvim-recorder)

简介：大幅简化和增强neovim自身的宏功能。允许你编辑、复制宏的内容以及设置断点

使用方法：快捷键使用

-   `q`：开始/结束录制宏
-   `Q`：执行当前选择的宏
-   `<A-q>`：切换宏槽位
-   `cq`：编辑当前槽位的宏
-   `yq`：复制当前槽位的宏

注：本配置仅使用了"u", "i", "o"三个槽位，如果需要更多槽位可以自行配置`slot`项。

配置：

```
{
    "chrisgrieser/nvim-recorder",
    lazy = true,
    keys = { "q", "Q", "<A-q>", "cq", "yq" },
    config = function()
        require("recorder").setup({
            slots = { "u", "i", "o" },
            mapping = {
                startStopRecording = "q",
                playMacro = "Q",
                switchSlot = "<A-q>",
                editMacro = "cq",
                yankMacro = "yq",
                -- addBreakPoint = "###",
            },
        })
    end,
}
```



## Reference:

1. https://github.com/ayamir/nvimdots
2. https://github.com/ADkun/lvim-config-suggest
3. https://github.com/gibfahn/dot (帮助我改写了coc-nvim的默认配置)



## FQA



### 很多地方都是空白或者显示的字符/icon都不太对。？

这是因为没有安装`Nerd-Font`，这是一系列包含了很多图标的字体，可以到 [Nerd-Font官网](https://www.nerdfonts.com/font-downloads) 下载。

-   by the way，我是用的是[monaco-nerd-fonts](https://github.com/Karmenzind/monaco-nerd-fonts), 你应该会注意到我把这个字体放置在了README相同的目录下

### 配置了插件以后，感觉很卡怎么办

打开lazy.nvim插件管理器的插件列表，然后按`P`进入`Profile`界面，然后按`<C-s>`按时间排序， 可以看到哪些插件使用的时间最多，考虑将这个插件卸载或使用更合理的lazy加载时机。 一般来说，如果按本文的给出的配置进行设置，不会出现特别卡顿的情况，除非电脑的配置太差，这时候可以考虑卸载一部分对性能影响很大的插件。

