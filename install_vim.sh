 #!/bin/sh

version=7.4
binary_error=""
software_path="$HOME/.softwareCache/"
url_prefix="ftp://ftp.vim.org/pub/vim/unix/"

download() {
	file_name=$(basename $1)
	file_path="${software_path}${file_name}"
	if [ ! -e $file_path ]; then
		echo "Downloading vim ..."
		mkdir -p $software_path
		cd $software_path
		if which wget > /dev/null; then
			wget $url
		elif which curl > /dev/null; then
			curl -fL $url
		else
			echo "wget or curl not found..."
			return 1
		fi
	else
		echo "vim install packages already exists..."
	fi
}

install_vim() {
	cd $software_path
	vim_dir="vim${version}"
	mkdir -p ${vim_dir}
	tar jxf $file_path --strip-components 1 -C ${vim_dir}
	cd ${vim_dir}

	if [ 1 -eq $1 ]; then
		awk 'BEGIN{print "#include <AvailabilityMacros.h>"}{print $0}' src/os_unix.h > src/os_unix.h
	else
		sudo yum install ncurses-devel zlib-devel openssl-devel sqlite-devel
	fi

	./configure --prefix=/usr/local/vim \
				--with-features=huge \
				--with-compiledby="iwannaflytomoon" \
				--enable-multibyte \
				--enable-pythoninterp=yes \
				--enable-cscope \
				--enable-fontset \
				--enable-rubyinterp
	make
	sudo make install
}

archi=$(uname -sm)
case "$archi" in
	Linux\ x86_64) download "${url_prefix}vim-${version}.tar.bz2";;
	Darwin\ x86_64) download "${url_prefix}vim-${version}.tar.bz2";;
esac

if [ ! -n "$binary_error" ]; then
case "$archi" in
	Linux\ x86_64) install_vim 0;;
	Darwin\ x86_64) install_vim 1;;
esac
	echo "vim install success!"	
else
	echo "  - $binary_error !!!"
	exit 1
fi
