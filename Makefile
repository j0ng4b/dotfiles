dotfiles:
	### Vim dotfiles
	mkdir -p ~/.vim/undos
	ln -sf $(PWD)/vim/* -t ~/.vim

