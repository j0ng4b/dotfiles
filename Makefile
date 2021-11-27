all: dotfiles vim-plugins

dirs:
	mkdir -p ~/.vim/undos/

dotfiles: dirs
	ln -sf $(PWD)/vim/vimrc -t ~/.vim/
	ln -sf $(PWD)/vim/pack -t ~/.vim/
	ln -sf $(PWD)/vim/options.vim -t ~/.vim/
	ln -sf $(PWD)/vim/keymaps.vim -t ~/.vim/

vim-plugins:
	git submodule init $(PWD)/vim/pack/
	git submodule update --depth 1
	vim -c 'helptags ALL' -c 'qa'

