#!/bin/bash
#You may edit $d to your desired directory and $f to your desired output filename.
#1st part: For every package name related to the valid directory files, the next line will shows its man, if any.
#2nd part: --- valid directory files and the next line will shows its man, if any
#3rd part: The last part will be package's description, home page, and maintainer contact.
d='/usr/bin/';
f=~/Downloads/mybin_usrbin_jan_18_2018.c;
d=${d%/}'/';
dc=${#d};
((dc++));
rm "$f" 2>/dev/null;
echo 'Start calculating total, please to be patient...';
total="$(find $d -type f -maxdepth 1 -exec dpkg -S {} + 2> /dev/null | wc -l)";
pkgn='';
n=0;
gn=0;
find "$d" -type f -maxdepth 1 -exec dpkg -S {} + 2> /dev/null | sort |
	while read -r fn; do
		((pgn=gn+1));
		echo "[$pgn/$total] Checking... $fn";
		pkgp="$pkgn";
		pkgn="$(echo $fn | cut -f1 -d' ')";
		pkgn="$(echo ${pkgn%:})";
		pkgbp="$(echo -n $fn | cut -f2- -d' ' | awk '{$1=$1}1')";
		pkgb="$(echo $pkgbp | cut -c$dc-)";
		((gn++));
		if [ "$pkgp" == "$pkgn" ]; then
			echo -en "\n--- $pkgb" >> "$f";
			ft="$(file -n -b -e elf $pkgbp | cut -d' ' -f1)";
			echo -e "\t\t($ft)" >> "$f";
			man -f "$pkgb" 2>/dev/null >> "$f";
			if [ "$total" == "$gn" ]; then
				echo -en '\n\n\t\t\t\t' >> "$f";
				dpkg-query -W -f='${Description}\n\n${Homepage}\nMaintainer: ${Maintainer}\n\n' "$pkgp" >>"$f";
				echo >> "$f";
			fi;
			continue;
		fi;
		if [ "$n" != 0 ]; then
			echo -en '\n\n\t\t\t\t' >> "$f";
			dpkg-query -W -f='${Description}\n\n${Homepage}\nMaintainer: ${Maintainer}\n\n' "$pkgp" >>"$f";
			echo >> "$f";
		fi;
		((n++));
		echo -n "[$n] " >> "$f";
		echo "$pkgn" >> "$f";
		man -f "$pkgn" 2>/dev/null >> "$f";
		echo -en "\n--- $pkgb" >> "$f";
		ft="$(file -n -b -e elf $pkgbp | cut -d' ' -f1)";
		echo -e "\t\t($ft)" >> "$f";
		man -f "$pkgb" 2>/dev/null >> "$f";
		if [ "$total" == "$gn" ]; then
			echo -en '\n\n\t\t\t\t' >> "$f";
			dpkg-query -W -f='${Description}\n\n${Homepage}\nMaintainer: ${Maintainer}\n\n' "$pkgn" >>"$f";
			echo >> "$f";
		fi;
	done;
if [ ! -f "$f" ]; then
	echo "Sorry, no file has brief";
else echo "Done ... Please check your file $f";
fi
