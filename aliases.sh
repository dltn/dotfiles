alias openpr='pr_url=$(gh pr view --json url -q .url 2>/dev/null) && [ -n "$pr_url" ] && open "$pr_url" || open "$(gh repo view --json url -q .url)/compare/$(git symbolic-ref --short HEAD)?expand=1"'
