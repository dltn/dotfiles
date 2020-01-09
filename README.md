# My dotfiles

## What are dotfiles?
See https://dotfiles.github.io

## Guiding Principles

My goal is to be able to run

```
git clone https://github.com/dltn/dotfiles
```

from any machine and instantly feel somewhat at home.

#### Standalone Directory over Magic (symlinking, side repos)

I used a slick [git-dir technique from @durdn's blog post](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/) 
for a while. This meant there was one snapshot maintained across all machines - "cloud drive" style. I found some snags:

* Any existing files (ex. DigitalOcean's default `.bashrc`, corporate configurations) would be clobbered.
* If I add machine-specific things to any tracked file they go everywhere.
  * Ex. Resource-hungry vim plugins end up on the underpowered IoT devices.
  * Ex. iOS development configurations end up on every non-Mac machine.
* If I want the same aliases to do slightly different things on different machines, I need to carefully handle branching logic.

Now I'm trying out a "care package" style - I clone this repo into a standalone folder and extract as I need.
Lightweight install scripts provide ease-of-use while preserving the choice of how *much* to bring in.

#### [Don't Get Too Crazy](https://en.wikipedia.org/wiki/KISS_principle)

My initial dotfile set was a compilation of cool ones I'd seen around the web.

My prompt, tmux, and editor all had beautiful coloring. However, when I'd combine ssh, tmux, mosh, and
vim - colors were distorted, basic commands failed for esoteric reasons that took afternoons to figure out
My life almost became [this XKCD comic](https://xkcd.com/1172/).

I've met developers who believe in never configuring/aliasing *anything*. I've also seen
[Powerline zsh prompts](https://github.com/b-ryan/powerline-shell) - so complex that each
return takes a second - that can't easily run bash from tutorials.

I think the ideal is somewhere in the middle, and that's where I'm aiming for here.


