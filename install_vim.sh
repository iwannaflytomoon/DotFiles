 #!/bin/sh

version=7.4
binary_error=""
software_path="$HOME/.softwareCache/"
url_prefix="ftp://ftp.vim.org/pub/vim/unix/"

CYAN='\033[0;36m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color]]]]'

download() {
	file_name=$(basename $1)
	file_path="${software_path}${file_name}"
	if [ ! -e $file_path ]; then
		printf "$BLUE Downloading vim ...$NC\n"
		mkdir -p $software_path
		cd $software_path
		if which wget > /dev/null; then
			wget $1
		elif which curl > /dev/null; then
			curl -fL $1
		else
			printf "$RED wget or curl not found...$NC\n"
			return 1
		fi
	else
		printf "$BLUE vim install packages already exists...$NC\n"
	fi
}

install_vim() {
	cd $software_path
	vim_dir="vim${version}"
	mkdir -p ${vim_dir}
	tar jxf $file_path --strip-components 1 -C ${vim_dir}
	cd ${vim_dir}

	if [ 1 -eq $1 ]; then
        sed -i "" '1i\
        #include <AvailabilityMacros.h>
        ' src/os_unix.h
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
	printf "$BLUE vim install success!$NC\n"
else
	printf "$RED - $binary_error !!!$NC\n"
	exit 1
fi
