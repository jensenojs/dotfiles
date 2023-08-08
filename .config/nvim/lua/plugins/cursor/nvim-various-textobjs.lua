-- https://github.com/chrisgrieser/nvim-various-textobjs
-- 为neovim新增很多textobjects，它们可以丰富你的快捷键选中、复制、修改等操作的体验
-- 使用方式：快捷键使用（以选中功能"v"来举例，可以替换为"c"（删除并修改）、"d"（删除）、"y"复制等）（i可以替换为a，i表示"inner"，a表示"outer"，如va}会选中包括}本身的内容，而vi}则不会）
-- viS：选中当前光标下的子word（如VimEnter，我们使用viw会选中整个VimEnter，但viS只会选中Enter或Vim）
-- vii：选中当前相同缩进的所有行
-- vR：选中当前相同缩进往后剩余的行
-- v%：选中当前光标下对应的括号结束位置
-- vr：选中剩余的段落
-- vgG：选中整个文件
-- v_：选中整行有字符的部分（除去空白字符）
-- viv：选中key-value的value部分
-- vik：选中key-value的key部分
-- vL：选中URL
-- vin：选中数字部分
-- v!：选中诊断部分（需要LSP）
-- vil：选中markdown的链接
-- viC：选中markdown的代码块部分
-- vic：选中css选择器
-- vi/：选中javascript的正则表达式pattern
-- viD：选中双中括号内容[[]]
return {
    "chrisgrieser/nvim-various-textobjs",
    lazy = true,
    event = {"User FileOpened"},
    config = function()
        require("various-textobjs").setup({
            useDefaultKeymaps = true,
            lookForwardLines = 10
        })
        -- example: `an` for outer subword, `in` for inner subword
        vim.keymap.set({"o", "x"}, "aS", function()
            require("various-textobjs").subword(false)
        end)
        vim.keymap.set({"o", "x"}, "iS", function()
            require("various-textobjs").subword(true)
        end)
    end
}
