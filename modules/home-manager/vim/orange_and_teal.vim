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
endif

hi! link Boolean Constant
hi! link Character Constant
hi! link Conditional Statement
hi! link Debug Special
hi! link Define PreProc
hi! link Delimiter Special
hi! link Exception Statement
hi! link Float Constant
hi! link Function Identifier
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link Macro PreProc
hi! link Number Constant
hi! link Operator Statement
hi! link PreCondit PreProc
hi! link Repeat Statement
hi! link SpecialChar Special
hi! link SpecialComment Special
hi! link StorageClass Type
hi! link Structure Type
hi! link Tag Special
hi! link Typedef Type

if (has('termguicolors') && &termguicolors) || has('gui_running')
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

  hi Normal guifg=#93a1a1 guibg=NONE gui=NONE cterm=NONE
  hi CursorLine guifg=NONE guibg=NONE gui=underline cterm=underline
  hi CursorLineNr guifg=#f78104 guibg=NONE gui=NONE cterm=NONE
  hi LineNr guifg=#586e75 guibg=NONE gui=NONE cterm=NONE
  hi Comment guifg=#586e75 guibg=NONE gui=italic cterm=italic
  hi Constant guifg=#2aa198 guibg=NONE gui=NONE cterm=NONE
  hi Identifier guifg=#268bd2 guibg=NONE gui=NONE cterm=NONE
  hi Statement guifg=#8ec07c guibg=NONE gui=NONE cterm=NONE
  hi PreProc guifg=#f78104 guibg=NONE gui=NONE cterm=NONE
  hi Type guifg=#b8bb26 guibg=NONE gui=NONE cterm=NONE
  hi Special guifg=#fd5901 guibg=NONE gui=NONE cterm=NONE
  hi Underlined guifg=#268bd2 guibg=NONE gui=underline cterm=underline
  hi Error guifg=#fd5901 guibg=NONE gui=bold,reverse cterm=bold,reverse
  hi Todo guifg=#a277ff guibg=NONE gui=bold,italic cterm=bold,italic
  hi Visual guifg=NONE guibg=NONE gui=reverse cterm=reverse
  hi Search guifg=#fe8019 guibg=NONE gui=reverse cterm=reverse
  hi IncSearch guifg=#f78104 guibg=NONE gui=reverse cterm=reverse
  hi StatusLine guifg=#93a1a1 guibg=NONE gui=reverse cterm=reverse
  hi StatusLineNC guifg=#586e75 guibg=NONE gui=reverse cterm=reverse
  hi VertSplit guifg=#586e75 guibg=NONE gui=NONE cterm=NONE
  hi TabLine guifg=#586e75 guibg=NONE gui=NONE cterm=NONE
  hi TabLineFill guifg=#586e75 guibg=NONE gui=NONE cterm=NONE
  hi TabLineSel guifg=#93a1a1 guibg=NONE gui=NONE cterm=NONE
  hi Folded guifg=#586e75 guibg=NONE gui=NONE cterm=NONE
  hi FoldColumn guifg=#586e75 guibg=NONE gui=NONE cterm=NONE
  hi SignColumn guifg=NONE guibg=NONE gui=NONE cterm=NONE
  hi Pmenu guifg=#93a1a1 guibg=#005F60 gui=NONE cterm=NONE
  hi PmenuSel guifg=#005F60 guibg=#93a1a1 gui=NONE cterm=NONE
  hi PmenuSbar guifg=NONE guibg=#586e75 gui=NONE cterm=NONE
  hi PmenuThumb guifg=NONE guibg=#93a1a1 gui=NONE cterm=NONE
  hi DiffAdd guifg=#8ec07c guibg=NONE gui=reverse cterm=reverse
  hi DiffChange guifg=#f78104 guibg=NONE gui=reverse cterm=reverse
  hi DiffDelete guifg=#fd5901 guibg=NONE gui=reverse cterm=reverse
  hi DiffText guifg=#268bd2 guibg=NONE gui=reverse cterm=reverse
  hi SpellBad guifg=#fd5901 guibg=NONE guisp=#fd5901 gui=undercurl cterm=underline
  hi SpellCap guifg=#268bd2 guibg=NONE guisp=#268bd2 gui=undercurl cterm=underline
  hi SpellRare guifg=#a277ff guibg=NONE guisp=#a277ff gui=undercurl cterm=underline
  hi SpellLocal guifg=#2aa198 guibg=NONE guisp=#2aa198 gui=undercurl cterm=underline
  
  " Add more highlight groups here as needed...

else
  " 16-color terminal configuration here...
endif
