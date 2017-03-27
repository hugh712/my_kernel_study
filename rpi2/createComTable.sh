#!/bin/bash

set -e

##################
# funciton define
##################

function install_Tools
{	
	set +e
	if [ -d /usr/local ]; then
		ToolPath="/usr/local/tools"
		sudo mkdir $ToolPath
		sudo chmod 777 $ToolPath
	elif [ -d ~/ ]; then
		ToolPath="~/tools"
	else
		ToolPath="$(pwd)/tools"
	fi

	#get Tools
	echo -e "\033[32m clone Toolchain to $ToolPath\033[0m"

	if [ -d $ToolPath/tools ]; then
		echo -e "\033[31m path exist -  $ToolPath/tools\033[0m"
	else
		git clone https://github.com/raspberrypi/tools $ToolPath
	fi


	#check bit
	if [ `uname -p` == "x86_64" ]; then
		BinPath="$ToolPath/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin"
	else
		BinPath="$ToolPath/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin"
	fi

	
	echo -e "\033[32m Toolchain Path is $BinPath\033[0m"
	if [ ! -d $BinPath ]; then
		echo -e "\033[31m can't find $BinPath\033[0m"
		exit 1
	fi

	# add to path
	if [ $(cat ~/.bashrc | grep PATH | grep $BinPath) ]; then
		echo -e "\033[31m PATH exist\033[0m"
	else
		echo -e "\033[31m PATH exist\033[0m"
	fi

	echo "export PATH=\$PATH:$BinPath" >> ~/.bashrc
	source ~/.bashrc
	echo $PATH


	set -e
}

function clone_Kernel
{
	if [ ! -d linux ]; then
		git clone --depth=1 https://github.com/raspberrypi/linux
	fi
	
}


function build_Kernel
{
	cd linux
	KERNEL=kernel7
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- vmlinux | tee ../build.log
	cd ..
}

function clean_Kernel
{
	cd linux 
	make clean
	cd ..
}

function cloc_Kernel
{
	echo "test"
}


function create_header
{
	echo "| Size | component name |" >> $1
	echo "|---|---|" >> $1
}

function create_content
{
	# get built-in.o in build.log
	 cat build.log | grep built-in.o | awk '{print "linux/"$2 }' | xargs du -hs | awk '{print "|" $1 "|" $2 "|"}' >> $1
	
}
function kernel_version
{
	cd linux
	echo "This report was analysis for linux kernel version" >> $1
	git log >> $1
	cd ..	
}

# main


#check input file
if [ $# -ne 1 ]; then	
		echo -e "\033[31m Usage: ./createComTable.sh file.md \033[0m"
		exit 1
fi
	
# clean parameter 1
echo "" > $1

# clone cross compile tool
#install_Tools

#clone and build kernel
clone_Kernel
#clean_Kernel
#cloc_Kernel $1
kernel_version $1
#build_Kernel


#assume we have build.log here

# create table
create_header $1
create_content $1
