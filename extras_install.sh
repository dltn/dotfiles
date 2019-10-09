# Download & install Nord theme (https://www.nordtheme.com)
echo "❄️  If you'd like to install Nord theme on your terminal emulator: https://www.nordtheme.com/ports"

echo "Installing Nord vim..."
mkdir -p ~/.vim/colors
curl https://raw.githubusercontent.com/arcticicestudio/nord-vim/master/colors/nord.vim > ~/.vim/colors/nord.vim
if ! grep -q "colo nord" ~/.vimrc
then
    echo "colo nord" >> ~/.vimrc
fi

# Download & install vimwiki plugin
# TODO: Add better package updating in this script
VIMWIKI_DIR=~/.vim/pack/plugins/start/vimwiki
if [ ! -d "$VIMWIKI_DIR" ]; then
    echo "Installing vimwiki..."
    git clone https://github.com/vimwiki/vimwiki.git $VIMWIKI_DIR
fi
