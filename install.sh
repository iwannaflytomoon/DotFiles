 #!/bin/sh

PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color]]]]'

symlink() {
	SRC=$PWD/$1
	DEST=~/.$1
	if [ -e "$DEST" ]; then
		printf "Skipping $RED$DEST$NC\n"
	else
		printf "Linking $CYAN$DEST -> $BLUE$SRC$NC\n"
		ln -s "$SRC" "$DEST"
	fi
}

symlink 'vim'
symlink 'gitconfig'
symlink 'gitignore'
symlink 'zshrc'
symlink 'tmux.conf'

install_omz() {
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
ln -s $PWD/half-life_kenan.zsh-theme ~/.oh-my-zsh/themes/half-life_kenan.zsh-theme
git clone git://github.com/jimmijj/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone git://github.com/rimraf/k ~/.oh-my-zsh/custom/plugins/k
git clone git://github.com/rupa/z ~/.oh-my-zsh/custom/plugins/z
}

install_omz
