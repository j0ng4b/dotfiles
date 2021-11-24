dirs:
	mkdir -p ~/.vim/undos

dotfiles: dirs
	ln -sf $(PWD)/vim/* -t ~/.vim

