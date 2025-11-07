" Name:         Orange and Teal
" Description:  Custom color scheme based on Solarized 8 with clear backgrounds
" Author:       Cem
" Maintainer:   Cem
" License:      MIT

set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = 'orange_and_teal'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2
let s:italics = (&t_ZH != '' && &t_ZH != '[7m') || has('gui_running')

if (has('termguicolors') && &termguicolors) || has('gui_running')
  let g:terminal_ansi_colors = [ 
    \ '#005F60', '#ff4500', '#8ec07c', '#f78104', '#268bd2', '#a277ff', '#2aa198', '#a6b2b2',
    \ '#7a8787', '#ff7f50', '#a9d196', '#ffa940', '#5eafed', '#c4a6ff', '#4ec2b8', '#a6b2b2']

  let s:base03  = '#062027'
  let s:base02  = '#005F60'
  let s:base01  = '#586e75'
  let s:base00  = '#657b83'
  let s:base0   = '#839496'
  let s:base1   = '#93a1a1'
  let s:base2   = '#eee8d5'
  let s:base3   = '#fdf6e3'

  let s:black   = '#005f60'
  let s:red     = '#ff4500'
  let s:green   = '#8ec07c'
  let s:yellow  = '#E6DB74'
  let s:orange  = '#f78104'
  let s:blue    = '#268bd2'
  let s:magenta = '#a277ff'
  let s:cyan    = '#2aa198'
  let s:teal    = '#005f60'
  let s:white   = '#a6b2b2'
  let s:gray    = '#7a8787'
  let s:pink    = '#F92772'
  let s:purered = '#ff0000'
  let s:darkred = '#5f0000'

  let s:light_red     = '#ff7f50'
  let s:light_green   = '#a9d196' 
  let s:light_yellow  = '#ffd54f'
  let s:light_orange  = '#ffa940'
  let s:light_blue    = '#5eafed'
  let s:light_magenta = '#c4a6ff'
  let s:light_cyan    = '#4ec2b8'
  let s:light_teal    = '#008080'
  let s:light_gray    = '#a6b2b2'

  let s:dim_red     = '#CC3700'
  let s:dim_green   = '#6F9A62'
  let s:dim_yellow  = '#b7950b'
  let s:dim_orange  = '#C46503'
  let s:dim_blue    = '#1E6EA8'
  let s:dim_magenta = '#815FCC'
  let s:dim_cyan    = '#1F7A72'
  let s:dim_gray    = '#849494'
  let s:dim_teal    = '#002F30'


  
  let s:addfg    = s:black
  let s:addbg    = s:green
  let s:delfg    = s:black
  let s:delbg    = s:red
  let s:changefg = s:black
  let s:changebg = s:orange



  function! s:hi(name, fg, bg, gui)
    execute 'hi' a:name 'guifg='.a:fg 'guibg='.a:bg 'gui='.a:gui 'cterm='.a:gui
  endfunction

  " Highlighting
  " ------------
  
  "  editor
  call s:hi('ColorColumn',     'NONE',    s:black,   'NONE')
  call s:hi('Cursor',          s:black,   'NONE',     'underline')
  call s:hi('CursorLine',      s:orange,  'NONE',    'underline')
  call s:hi('CursorLineNr',    s:orange,  'NONE',   'NONE')
  call s:hi('ErrorMsg',        s:black,   s:red,     'NONE')
  call s:hi('IncSearch',       s:orange,  'NONE',    'reverse')
  call s:hi('LineNr',          s:base01,  'NONE',    'NONE')
  call s:hi('MatchParen',      s:orange,  'NONE',    'reverse')
  call s:hi('ModeMsg',         s:orange,  'NONE',    'NONE')
  call s:hi('MoreMsg',         s:orange,  'NONE',    'NONE')
  call s:hi('Normal',          s:base1,   'NONE',    'NONE')
  call s:hi('NonText',         s:base02,  'NONE',    'NONE')
  call s:hi('Question',        s:orange,  'NONE',    'NONE')
  call s:hi('Search',          s:orange,  'NONE',    'reverse')
  call s:hi('SignColumn',      'NONE',    s:black,    'NONE')
  call s:hi('VertSplit',       s:base01,  'NONE',    'NONE')
  call s:hi('Visual',          'NONE',    'NONE',    'reverse')
  call s:hi('WarningMsg',      s:red,     'NONE',    'NONE')

  " statusline
  "call s:hi('StatusLine',      s:base1,   'NONE',    'reverse')
  call s:hi('StatusLine',      s:orange,   s:black,    'NONE')
  call s:hi('StatusLineNC',    s:base01,   'NONE',    'reverse')
  call s:hi('TabLine',         s:light_gray,s:black,    'NONE')
  call s:hi('TabLineFill',     s:base01,   'NONE',    'NONE')
  call s:hi('TabLineSel',      s:base1,    'NONE',    'NONE')
  call s:hi('User1',           s:orange,   'NONE',    'NONE')
  call s:hi('User2',           s:yellow,   'NONE',    'NONE')
  call s:hi('User3',           s:magenta,  'NONE',    'NONE')
  call s:hi('User4',           s:cyan,     'NONE',    'NONE')

  " spell
  call s:hi('SpellBad',        s:red,      'NONE',    'undercurl')
  call s:hi('SpellCap',        s:blue,     'NONE',    'undercurl')
  call s:hi('SpellRare',       s:magenta,  'NONE',    'undercurl')
  call s:hi('SpellLocal',      s:cyan,     'NONE',    'undercurl')

  " misc
  call s:hi('SpecialKey',      s:pink,     'NONE',    'NONE')
  call s:hi('Title',           s:yellow,   'NONE',    'NONE')
  call s:hi('Directory',       s:cyan,     'NONE',    'NONE')

  " diff
  call s:hi('DiffAdd',         s:addfg,     s:addbg,    'NONE')
  call s:hi('DiffChange',      s:changefg,  s:changebg, 'NONE')
  call s:hi('DiffDelete',      s:delfg,     s:delbg,    'NONE')
  call s:hi('DiffText',        s:black,     s:cyan,     'NONE')

  " fold
  call s:hi('Folded',          s:yellow,    s:black,    'NONE')
  call s:hi('FoldColumn',      s:yellow,    'NONE',    'NONE')

  " popup menu
  call s:hi('Pmenu',           s:white,     'NONE',    'NONE')
  call s:hi('PmenuSel',        s:white,     s:black,    'NONE')
  call s:hi('PmenuSbar',       'NONE',      s:dim_teal,    'bold')
  call s:hi('PmenuThumb',      'NONE',      s:black,    'NONE')

  " Generic Syntax Highlighting
  " ---------------------------
  "
  call s:hi('Constant',        s:cyan,      'NONE',    'bold')
  call s:hi('Boolean',         s:magenta,   'NONE',    'NONE')
  call s:hi('Float',           s:magenta,   'NONE',    'NONE')
  call s:hi('Number',          s:magenta,   'NONE',    'NONE')
  call s:hi('Character',       s:yellow,    'NONE',    'NONE')
  call s:hi('String',          s:base1,     'NONE',    'NONE')
  
  call s:hi('Type',            s:cyan,      'NONE',    'NONE')
  call s:hi('Structure',       s:cyan,      'NONE',    'NONE')
  call s:hi('StorageClass',    s:cyan,      'NONE',    'NONE')
  call s:hi('Typedef',         s:cyan,      'NONE',    'NONE')

  call s:hi('Identifier',      s:blue,      'NONE',    'NONE')
  call s:hi('Function',        s:blue,      'NONE',    'NONE')

  call s:hi('Statement',       s:orange,    'NONE',    'NONE')
  call s:hi('Operator',        s:red,     'NONE',    'NONE')
  call s:hi('Label',           s:red,       'NONE',    'NONE')
  call s:hi('Keyword',         s:pink,    'NONE',    'NONE')
  " call s:hi('Conditional',     s:pink,    'NONE',    'NONE')
  " call s:hi('Repeat',          s:pink,    'NONE',    'NONE')
  call s:hi('Exception',       s:pink,    'NONE',    'NONE')

  call s:hi('PreProc',         s:green,     'NONE',    'NONE')
  call s:hi('Include',         s:orange,    'NONE',    'NONE')
  call s:hi('Define',          s:orange,    'NONE',    'NONE')
  call s:hi('Macro',           s:green,     'NONE',    'NONE')
  call s:hi('PreCondit',       s:green,     'NONE',    'NONE')

  call s:hi('Special',         s:red,     'NONE',    'NONE')
  call s:hi('SpecialChar',     s:red, 'NONE',    'NONE')
  call s:hi('Delimiter',       s:red, 'NONE',    'NONE')
  call s:hi('SpecialComment',  s:cyan,      s:teal,    'NONE')
  call s:hi('Tag',             s:orange,    'NONE',    'NONE')
  call s:hi('Debug',           s:blue,      'NONE',    'NONE')

  call s:hi('Todo',            s:dim_yellow,    s:teal,    'bold,italic')
  call s:hi('Comment',         s:base01,    'NONE',    'italic')

  call s:hi('Underlined',      s:blue,      'NONE',    'underline')
  call s:hi('Ignore',          'NONE',      'NONE',    'NONE')
  call s:hi('Error',           s:red,       s:dim_red, 'bold')

  " NIX
  " ---
  call s:hi('nixSimpleBuiltin',          s:blue,    'NONE',    'NONE') " fetchGit map mapAttrs import tString ...

  call s:hi('nixAttribute',              s:green,   'NONE',    'NONE') " asdf =
  call s:hi('nixAttributeDefinition',    s:green,   'NONE',    'NONE') " attr...;

  call s:hi('nixBuiltin',                s:magenta, 'NONE',    'NONE') " builtins.
  call s:hi('nixInteger',                s:magenta, 'NONE',    'NONE') " 42
  call s:hi('nixRecKeyword',             s:magenta, 'NONE',    'NONE') " rec
  call s:hi('nixSearchPathRef',          s:magenta, 'NONE',    'NONE') " fetchGit map mapAttrs import tString ...
  call s:hi('nixSimpleFunctionArgument', s:magenta, 'NONE',    'NONE')
  call s:hi('nixSimpleStringSpecial',    s:magenta, 'NONE',    'NONE')

  call s:hi('nixArgOperator',            s:orange,  'NONE',    'NONE') " @ 
  call s:hi('nixArgumentDefinition',     s:orange,  'NONE',    'NONE') " { arg1, arg2 }
  call s:hi('nixExpr',                   s:orange,  'NONE',    'NONE') " 
  call s:hi('nixFunctionArgument',       s:orange,  'NONE',    'NONE')
  call s:hi('nixFunctionCall',           s:orange,  'NONE',    'NONE') " [ a b c ]
  call s:hi('nixInterpolationParam',     s:orange,  'NONE',    'NONE') " ${param}
  call s:hi('nixNamespacedBuiltin',      s:orange,  'NONE',    'NONE') " builtins.smth
  call s:hi('nixTodo',                   s:orange,  'NONE',    'NONE')

  call s:hi('nixArgumentEllipsis',       s:pink,    'NONE',    'NONE') " { arg1, ... }
  call s:hi('nixArgumentSeparator',      s:pink,    'NONE',    'NONE') " { arg1, }
  call s:hi('nixAttributeDot',           s:pink,    'NONE',    'NONE') " xy.z 
  call s:hi('nixAttributeAssignment',    s:pink,    'NONE',    'NONE') " =
  call s:hi('nixInherit',                s:pink,    'NONE',    'NONE')
  call s:hi('nixInterpolationDelimiter', s:pink,    'NONE',    'NONE') " ${}
  call s:hi('nixLetExpr',                s:pink,    'NONE',    'NONE') " let
  call s:hi('nixLetExprKeyword',         s:pink,    'NONE',    'NONE') " let
  call s:hi('nixList',                   s:pink,    'NONE',    'NONE') " nix.lib. (dots)
  call s:hi('nixListBracket',            s:pink,    'NONE',    'NONE')
  call s:hi('nixWithExpr',               s:pink,    'NONE',    'NONE')
  call s:hi('nixWithExprKeyword',        s:pink,    'NONE',    'NONE') " with

  call s:hi('nixAttributeSet',           s:white,   'NONE',    'NONE') " { }
  call s:hi('nixInterpolation',          s:white,   'NONE',    'NONE')
  call s:hi('nixParen',                  s:white,   'NONE',    'NONE')

  call s:hi('nixPath',                   s:yellow,  'NONE',    'NONE') " well paths...
  call s:hi('nixSimpleString',           s:yellow,  'NONE',    'NONE')
  call s:hi('nixString',                 s:yellow,  'NONE',    'NONE')
  call s:hi('nixStringDelimiter',        s:yellow,  'NONE',    'NONE')
  call s:hi('nixStringSpecial',          s:yellow,  'NONE',    'NONE')

  " Commented out lines
  " call s:hi('nixInheritAttributeScope',                   s:magenta,  'NONE',    'NONE')
  " call s:hi('nixAttribuetSet',                   s:magenta,  'NONE',    'NONE')
  " call s:hi('nixArgumntDefinitionWithDefault',                   s:red,  'NONE',    'NONE')
  " call s:hi('nixIfExpr',             s:magenta,  'NONE',    'NONE')
  " call s:hi('nixAssertExpr',                   s:magenta,  'NONE',    'NONE')

  " HCL
  " ---
  call s:hi('hclAttributeAssignment',    s:red,     'NONE',    'NONE')
  call s:hi('hclBlockBody',              s:magenta, 'NONE',    'NONE')
  call s:hi('hclConditional',            s:red,     'NONE',    'NONE')
  call s:hi('hclRepeat',                 s:red,     'NONE',    'NONE')
  call s:hi('hclStringInterp',           s:red,     'NONE',    'NONE')
  call s:hi('hclValueString',            s:orange,  'NONE',    'NONE')

  call s:hi('terraType',                 s:green,    'NONE',    'NONE')
  " call s:hi('terraKeyword',              s:red,    'NONE',    'NONE')

  " Link highlight groups
  hi! link ColorColumn  CursorLine
  hi! link Conceal      Normal
  hi! link MoreMsg      Normal
  hi! link Question     Normal
  hi! link VisualNOS    Visual
  hi! link WildMenu     PmenuSel

else
  " 16-color terminal configuration
  let s:term_base03  = '8'
  let s:term_base02  = '0'
  let s:term_base01  = '10'
  let s:term_base00  = '11'
  let s:term_base0   = '12'
  let s:term_base1   = '14'
  let s:term_base2   = '7'
  let s:term_base3   = '15'
  let s:term_red     = '1'
  let s:term_orange  = '9'
  let s:term_yellow  = '3'
  let s:term_green   = '2'
  let s:term_cyan    = '6'
  let s:term_blue    = '4'
  let s:term_violet  = '13'
  let s:term_magenta = '5'

  function! s:hi(name, fg, bg, attr)
    execute 'hi' a:name 'ctermfg='.a:fg 'ctermbg='.a:bg 'cterm='.a:attr
  endfunction

  " Define terminal color scheme (simplified version)
  call s:hi('Normal',          s:term_base1,   'NONE',         'NONE')
  call s:hi('CursorLine',      'NONE',         'NONE',         'underline')
  call s:hi('CursorLineNr',    s:term_orange,  'NONE',         'NONE')
  call s:hi('LineNr',          s:term_base01,  'NONE',         'NONE')
  call s:hi('Comment',         s:term_base01,  'NONE',         'italic')
  call s:hi('Constant',        s:term_cyan,    'NONE',         'NONE')
  call s:hi('Identifier',      s:term_blue,    'NONE',         'NONE')
  call s:hi('Statement',       s:term_green,   'NONE',         'NONE')
  call s:hi('PreProc',         s:term_orange,  'NONE',         'NONE')
  call s:hi('Type',            s:term_yellow,  'NONE',         'NONE')
  call s:hi('Special',         s:term_red,     'NONE',         'NONE')
  call s:hi('Underlined',      s:term_blue,    'NONE',         'underline')
  call s:hi('Error',           s:term_red,     'NONE',         'bold,reverse')
  call s:hi('Todo',            s:term_magenta, 'NONE',         'bold,italic')
  
  " Add more highlight groups for the terminal version as needed...
endif
