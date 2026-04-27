{
  tgrey = ''tmux set-option -g status-bg "#282c34"'';
  torange = ''tmux set-option -g status-bg "#062027"'';

  nixswitch = "make -C ~/.config/nix switch";
  nixup = "make -C ~/.config/nix update";
  nixclean = "make -C ~/.config/nix clean";
  nixe = "(cd ~/.config/nix && nvim && nixswitch) && clear";

  homelab = "make -C ~/.config/nix deploy";
  synchomelab = "make -C ~/.config/nix sync";

  nvime = "(cd ~/.config/nvim && nvim) && clear";

  cat = "bat";

  l = "ll";
  la = "lla";
  lt = "ll --tree --git-ignore";

  cd = "z";
  cdr = ''
    cd $(cat <(find ~/dev/personal -mindepth 1 -maxdepth 1 -type d) <(find ~/dev/work -mindepth 1 -maxdepth 2 -type d) \
            | fzf --tmux='80%' --preview-window='50%,right' --layout=reverse --preview='eza --tree --colour=always {}')'';

  v = "nvim";
  iv = "nvim";
  # vi = "nvim";
  # vim = "nvim";
  vmi = "nvim";
  nvi = "nvim";
  nvimi = "nvim";

  # neovide = "(neovide.exe --frame=none --wsl &)";

  cfile = ''\cat "$(fzf)" | pbcopy'';

  tadev = "ENV=dev terragrunt apply";
  tddev = "ENV=dev terragrunt destroy";
  taprod = "ENV=prod terragrunt apply";
  tdprod = "ENV=prod terragrunt destroy";

  k = "kubectl";
  kc = "kubectl config current-context";
  kn = ''kubectl get ns --no-headers | awk '{print $1}' | fzf | xargs -I {} kubectl config set-context --current --namespace "{}"'';
  ks = ''kubectl config get-contexts -o name | fzf | xargs -I {} kubectl config use-context "{}"'';

  # Git
  gc = "git commit --message";
  gpt = "git push --tags";
  gld = "git log -p --oneline --ext-diff";
  gD = "git diff HEAD~1";
  # interactively browse commits, opening them in Diffview on select
  gdi = ''git log --oneline | fzf --preview 'git show --name-only {1}' --bind "enter:execute(nvim -c 'DiffviewOpen {1}^!' 'Neotree toggle' -- . ':(exclude)flake.lock' ':(exclude)nvim/lazy-lock.json' '(exclude)yarn.lock')"'';
  # diff between HEAD and the main branch
  gdm = ''nvim -c "DiffviewOpen" "Neotree toggle"'';
  # clean up branches that have also been deleted in remote
  gprune = ''git remote prune origin && git for-each-ref --format "%(refname:short)" refs/heads | grep -v "master\|main" | xargs git branch -D'';
  gwtcd = "cd $(git worktree list | grep -v '(bare)' | awk '{print $1}' | fzf)";
  gwtrm = "git worktree remove $(git worktree list | grep -v '(bare)' | awk '{print $1}' | fzf)";
  # delete local branches that have been merged into main (except for the develop branch)
  gclean = ''git branch --merged origin/main | grep -vE "^\s*(\*|main|develop)" | xargs -n 1 git branch -d'';
  # Git Count Lines in Branch
  gclb = "git diff main...HEAD --stat | tail -1";

  vimtip = ''
    curl -w "
    " https://vtip.43z.one'';

  tsesh = "tmux-sessionizer";
  ts = "tmux-sessionizer";

  lg = "lazygit";
}
