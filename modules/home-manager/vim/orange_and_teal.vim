" Name:         Orange and Teal
" Description:  Custom color scheme based on Solarized 8 with clear backgrounds
" Author:       Cem
" Maintainer:   Cem
" License:      OSI approved MIT license
" Last Updated: 27.07.2024

hi clear
let g:colors_name = 'orange_and_teal'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2
let s:italics = (&t_ZH != '' && &t_ZH != '[7m') || has('gui_running')

if (has('termguicolors') && &termguicolors) || has('gui_running')
  let g:terminal_ansi_colors = ['#005F60', '#fd5901', '#8ec07c', '#f78104', '#268bd2', '#a277ff', '#2aa198', '#93a1a1', '#005F60', '#ff4500', '#b8bb26', '#fe8019', '#83a598', '#b16286', '#689d6a', '#c5c8c6']

  let s:base03  = '#062027'
  let s:base02  = '#005F60'
  let s:base01  = '#586e75'
  let s:base00  = '#657b83'
  let s:base0   = '#839496'
  let s:base1   = '#93a1a1'
  let s:base2   = '#eee8d5'
  let s:base3   = '#fdf6e3'
  let s:red     = '#fd5901'
  let s:orange  = '#f78104'
  let s:yellow  = '#fe8019'
  let s:green   = '#8ec07c'
  let s:cyan    = '#2aa198'
  let s:blue    = '#268bd2'
  let s:violet  = '#6c71c4'
  let s:magenta = '#a277ff'
  let s:trueyellow  = '#ffff00'


  function! s:hi(name, fg, bg, gui)
    execute 'hi' a:name 'guifg='.a:fg 'guibg='.a:bg 'gui='.a:gui 'cterm='.a:gui
  endfunction

  call s:hi('Normal',          s:base1,   'NONE',    'NONE')
  call s:hi('CursorLine',      'NONE',    'NONE',    'underline')
  call s:hi('CursorLineNr',    s:orange,  'NONE',    'NONE')
  call s:hi('LineNr',          s:base01,  'NONE',    'NONE')
  call s:hi('Comment',         s:base01,  'NONE',    'italic')
  call s:hi('Constant',        s:cyan,    'NONE',    'NONE')
  call s:hi('Identifier',      s:green,    'NONE',    'NONE')
  call s:hi('Statement',       s:green,   'NONE',    'NONE')
  call s:hi('PreProc',         s:orange,  'NONE',    'NONE')
  call s:hi('Type',            s:yellow,  'NONE',    'NONE')
  call s:hi('Special',         s:red,     'NONE',    'NONE')
  call s:hi('Underlined',      s:blue,    'NONE',    'underline')
  call s:hi('Error',           s:red,     'NONE',    'bold,reverse')
  call s:hi('Todo',            s:magenta, 'NONE',    'bold,italic')
  call s:hi('Visual',          'NONE',    'NONE',    'reverse')
  call s:hi('Search',          s:yellow,  'NONE',    'reverse')
  call s:hi('IncSearch',       s:orange,  'NONE',    'reverse')
  call s:hi('StatusLine',      s:base1,   'NONE',    'reverse')
  call s:hi('StatusLineNC',    s:base01,  'NONE',    'reverse')
  call s:hi('VertSplit',       s:base01,  'NONE',    'NONE')
  call s:hi('TabLine',         s:base01,  'NONE',    'NONE')
  call s:hi('TabLineFill',     s:base01,  'NONE',    'NONE')
  call s:hi('TabLineSel',      s:base1,   'NONE',    'NONE')
  call s:hi('Folded',          s:base01,  'NONE',    'NONE')
  call s:hi('FoldColumn',      s:base01,  'NONE',    'NONE')
  call s:hi('SignColumn',      'NONE',    'NONE',    'NONE')
  call s:hi('Pmenu',           s:base1,   'NONE',  'NONE')
  call s:hi('PmenuSel',        s:base02,  'NONE',   'NONE')
  call s:hi('PmenuSbar',       'NONE',    'NONE',  'NONE')
  call s:hi('PmenuThumb',      'NONE',    'NONE',   'NONE')
  call s:hi('DiffAdd',         s:green,   'NONE',    'reverse')
  call s:hi('DiffChange',      s:orange,  'NONE',    'reverse')
  call s:hi('DiffDelete',      s:red,     'NONE',    'reverse')
  call s:hi('DiffText',        s:blue,    'NONE',    'reverse')
  call s:hi('SpellBad',        s:red,     'NONE',    'undercurl')
  call s:hi('SpellCap',        s:blue,    'NONE',    'undercurl')
  call s:hi('SpellRare',       s:magenta, 'NONE',    'undercurl')
  call s:hi('SpellLocal',      s:cyan,    'NONE',    'undercurl')

  " Additional highlights from bat scheme
  call s:hi('Attribute',       s:yellow,  'NONE',    'NONE')
  call s:hi('Boolean',         s:magenta, 'NONE',    'NONE')
  call s:hi('Character',       s:magenta, 'NONE',    'NONE')
  call s:hi('Conditional',     s:red,     'NONE',    'NONE')
  call s:hi('Define',          s:blue,    'NONE',    'NONE')
  call s:hi('ErrorMsg',        s:base1,   'NONE',    'NONE')
  call s:hi('WarningMsg',      s:base1,   'NONE',    'NONE')
  call s:hi('Float',           s:magenta, 'NONE',    'NONE')
  call s:hi('Function',        s:green,   'NONE',    'NONE')
  call s:hi('Include',         s:red,     'NONE',    'NONE')
  call s:hi('Keyword',         s:blue,    'NONE',    'NONE')
  call s:hi('Label',           s:yellow,  'NONE',    'NONE')
  call s:hi('NonText',         s:base02,  'NONE',  'NONE')
  call s:hi('Number',          s:magenta, 'NONE',    'NONE')
  call s:hi('Operator',        s:red,     'NONE',    'NONE')
  call s:hi('PreProc',         s:blue,    'NONE',    'NONE')
  call s:hi('SpecialKey',      s:base02,  'NONE',    'NONE')
  call s:hi('StorageClass',    s:cyan,    'NONE',    'NONE')
  call s:hi('String',          s:yellow,  'NONE',    'NONE')
  call s:hi('Tag',             s:blue,    'NONE',    'NONE')
  call s:hi('Title',           s:base1,   'NONE',    'bold')

  " Link highlight groups
  hi! link ColorColumn  CursorLine
  hi! link Conceal      Normal
  hi! link CursorColumn CursorLine
  hi! link Directory    Identifier
  hi! link MatchParen   Search
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

