# Download & install Nord theme (https://www.nordtheme.com)
echo "❄️  If you'd like to install Nord theme on your terminal emulator: https://www.nordtheme.com/ports"

NORD_VIM=~/.vim/colors/nord.vim
if [ ! -f "$NORD_VIM" ]; then
    echo "Installing Nord vim to {$NORD_VIM}..."
    mkdir -p ~/.vim/colors
    curl https://raw.githubusercontent.com/arcticicestudio/nord-vim/master/colors/nord.vim > $NORD_VIM
fi

if ! grep -q "colo nord" ~/.vimrc
then
    script=$(basename -- "$0")
    echo "colo nord \" added by "$script >> ~/.vimrc
fi

# Download & install vimwiki plugin
# TODO: Add better package updating in this script
VIMWIKI_DIR=~/.vim/pack/plugins/start/vimwiki
if [ ! -d "$VIMWIKI_DIR" ]; then
    echo "Installing vimwiki to {$VIMWIKI_DIR}..."
    git clone https://github.com/vimwiki/vimwiki.git $VIMWIKI_DIR
fi

# Download & install tpm (tmux plugin manager)
# TODO: Add better package updating in this script
TPM_DIR=~/.tmux/plugins/tpm
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing tpm to {$TPM_DIR}..."
    git clone https://github.com/tmux-plugins/tpm $TPM_DIR
fi
