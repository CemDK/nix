{
  tcol_grey = ''tmux set-option -g status-bg "#282c34"'';
  tcol_orange = ''tmux set-option -g status-bg "#005F60"'';

  nixup = "pushd ~/.config/nix; nix flake update; nixswitch; popd";
  nixclean = "nix-store --gc && nix-collect-garbage --delete-older-than 30d";
  nixe = "pushd ~/.config/nix && vi && nixswitch --impure && popd";

  nvime = "pushd ~/.config/nvim && vi && popd";

  cat = "bat";

  l = "ll";
  la = "lla";
  lt = "ll --tree --git-ignore";

  cd = "z";
  cdr =
    "cd $(find ~/dev -mindepth 1 -maxdepth 2 -type d | fzf --tmux='80%' --preview-window='50%,right' --layout=reverse --preview='eza --tree --colour=always {}')";

  v = "vi";
  iv = "vi";
  vim = "vi";
  vmi = "vi";
  nv = "vi";
  nvi = "vi";
  nvim = "vi";
  nvimi = "vi";
  vi = "(fs &); (tcol_grey &); nvim; (tcol_orange &); clear; (fs &)";

  cfile = "cat $(fzf) | pbcopy";

  tadev = "ENV=dev terragrunt apply";
  tddev = "ENV=dev terragrunt destroy";
  taprod = "ENV=prod terragrunt apply";
  tdprod = "ENV=prod terragrunt destroy";

  k = "kubectl";
  kc = "kubectl config current-context";
  kn = ''
    kubectl get ns --no-headers | awk '{print $1}' | fzf | xargs -I {} kubectl config set-context --current --namespace "{}"'';
  ks = ''
    kubectl config get-contexts -o name | fzf | xargs -I {} kubectl config use-context "{}"'';

  # Git
  gc = "git commit --message";
  gpt = "git push --tags";
  gld = "git log -p --oneline --ext-diff";
  gD = "git diff HEAD~1";
  # interactively browse commits, opening them in Diffview on select
  gdi = ''
    git log --oneline | fzf --preview 'git show --name-only {1}' --bind "enter:execute(nvim -c 'DiffviewOpen {1}^!' 'Neotree toggle' -- . ':(exclude)flake.lock' ':(exclude)nvim/lazy-lock.json' '(exclude)yarn.lock')"'';
  # diff between HEAD and the main branch
  gdm = ''nvim -c "DiffviewOpen" "Neotree toggle"'';
  # clean up branches that have also been deleted in remote
  gprune = ''
    git remote prune origin && git for-each-ref --format "%(refname:short)" refs/heads | grep -v "master\|main" | xargs git branch -D'';
  gwtcd = "cd $(git worktree list | grep -v '(bare)' | awk '{print $1}' | fzf)";
  gwtrm =
    "git worktree remove $(git worktree list | grep -v '(bare)' | awk '{print $1}' | fzf)";

  vimtip = ''
    curl -w "
    " https://vtip.43z.one'';

  tsesh = "tmux-sessionizer";
}
