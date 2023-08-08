-- 在文本两端有一对双引号,现在我想把它变为一对单引号, 在普通模式下使用 cs" ' 命令 (以下的操作都是在普通模式下进行)
-- "Hello world!"
-- 现在它变成了一对单引号
-- 'Hello world!'
-- 现在我想把这对单引号变为一对 < q > 标签 可以使用 cs ' < q > 命令完成
-- <q>Hello world!</q>
-- 现在我想把这对 < q >标签换回 双引号 ,可以使用 cst " 命令
-- "Hello world!"
-- 现在我想去除这对双引号 , 可以使用 ds " 命令
-- Hello world!
-- 现在我想用 一对方括号 将 'Hello' 包起来, 可以使用 ysiw] 命令 ( iw 代表的是文本对象 ,指的是光标下所在的单词).
-- [Hello] world!
-- 现在我想用 花括号 将 'Hello' 包起来 并在单词两端各添加一个空格 , 可以使用 cs]{ 命令
-- { Hello } world!
-- 现在我想在整体这个字符串上加上一对括号 ,可以使用 yssb 或 yss) 命令
-- ({ Hello } world!)
-- 现在我想要把这一对括号和花括号去除 , 可以使用 ds{ds) 命令
-- Hello world!
return {
    'tpope/vim-surround',
    config = function()

    end
}
