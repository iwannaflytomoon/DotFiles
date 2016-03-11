 #!/bin/sh

version=7.4
is_error=0
software_path="$HOME/.softwareCache/"
url_prefix="ftp://ftp.vim.org/pub/vim/unix/"
intsall_path="/usr/local/vim"

PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color]]]]'

download() {
	file_name=$(basename $1)
	file_path="${software_path}${file_name}"
	if [ ! -e $file_path ]; then
		printf "$RED Downloading $1 ...$NC\n"
		mkdir -p $software_path
		cd $software_path
		if which wget > /dev/null; then
			wget $1
		elif which curl > /dev/null; then
			curl -fL $1
		else
			printf "$RED wget or curl not found...$NC\n"
			is_error=1	
			return 1
		fi
	else
		printf "$RED $1 already exists...$NC\n"
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
	#else
		#sudo yum install ncurses-devel zlib-devel openssl-devel sqlite-devel
	fi

	printf "$CYAN Where do you want to install?(Default:/usr/local/vim)$NC "
	read answer
	if [ -d $answer ]; then
		if [ -n "$answer" ]; then
			install_path=$answer
		fi
	else
		printf "$RED input path error!$NC\n"
	    is_error=1
		return 1
	fi 
	
	#judge install_path writeable
	touch $install_path/.test_writeable 
	if [ 0 -eq $? ]; then
		is_writeable=1
		rm -f $install_path/.test_writeable
	else
		is_writeable=0
	fi
	./configure --prefix=${install_path} \
				--with-features=huge \
				--with-compiledby="kenan" \
				--enable-multibyte \
				--enable-pythoninterp=yes \
				--enable-cscope \
				--enable-fontset \
				--enable-rubyinterp \
				--quiet
	make --quiet distclean
	make --quiet clean
	make --quiet
	if [ 1 -eq $is_writeable ]; then
		make --quiet install
	else
		sudo make install
	fi

	if [ 0 -ne $? ]; then
		printf "$RED vim install failed!$NC\n"
		is_error=1
	fi
}

ask() {
	printf  "$CYAN $1 ([y]/n) $NC  "
	read answer
	[[ $answer =~ ^[Nn]$ ]]
}

install_vimdoc() {
	printf "$PURPLE install vimdoc...$NC\n"
	url="http://sourceforge.net/projects/vimcdoc/files/vimcdoc/vimcdoc-1.9.0.tar.gz"
	download $url
	file_name=$(basename $url)
	vimdoc_dir="vimdoc"
	cd $software_path
	mkdir -p $vimdoc_dir
	tar zxf $file_name --strip-components 1 -C ${vimdoc_dir}
	cd ${vimdoc_dir}
	./vimcdoc.sh -I

	if [ 0 -ne $? ]; then
		printf "$RED vimdoc install failed!$NC\n"
		is_error=1
	else
		printf "$RED vimdoc install succecc!$NC\n"
	fi
}

archi=$(uname -sm)
case "$archi" in
	Linux\ x86_64) download "${url_prefix}vim-${version}.tar.bz2";;
	Darwin\ x86_64) download "${url_prefix}vim-${version}.tar.bz2";;
esac

if [ 0 -eq $is_error ]; then
case "$archi" in
	Linux\ x86_64) install_vim 0;;
	Darwin\ x86_64) install_vim 1;;
esac
fi
if [ 0 -eq $is_error ]; then
	printf "$RED vim install success!!!$NC\n"
else
	printf "$RED vim install fail!!!$NC\n"
	exit
fi

ask "Do you want to vim's chinese doc?"
if [ 1 -eq $? ]; then
	install_vimdoc
fi
