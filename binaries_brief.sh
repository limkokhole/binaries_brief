#!/bin/bash
#You may edit $d to your desired directory and $f to your desired output filename.
#1st part: For every package name related to the valid directory files, the next line will shows its man, if any.
#2nd part: --- valid directory files and the next line will shows its man, if any
#3rd part: The last part will be package's description, home page, and maintainer contact.
d='/usr/bin/';
f=~/Downloads/mybin_usrbin_jan_18_2018.c;
d=${d%/}'/'; #to support path either '/' or no '/'
dc=${#d}; #count path size
((dc++));
rm "$f" 2>/dev/null;
echo 'Start calculating total, please to be patient...';
#total="$(find $d -maxdepth 1 -name '*parallel*' -type f -exec dpkg -S {} + 2> /dev/null | wc -l)"; #if want test custom name #1
total="$(find $d -maxdepth 1 -type f -exec dpkg -S {} + 2> /dev/null | wc -l)"; #note that only 1 maxdepth to avoid too heavy
pkgn='';
n=0;
gn=0;
contains_space=" |'";

#dpkg -S produces such special cases output line(s)
#... , only case #2 supported, the rest will ignore and shows 'multi-packages not supported...':
#Special case 1(,): libgl1-mesa-dri:i386, libgl1-mesa-dri:amd64: /etc/drirc
#Special case 2(:): libmagic1:amd64: /etc/magic
#Special case 3: diversion by parallel from: /usr/bin/parallel
#Special case 4: diversion by parallel to: /usr/bin/parallel.moreutils
#Special case 5: parallel, moreutils: /usr/bin/parallel

#find "$d" -maxdepth 1 -name '*parallel*' -type f -exec dpkg -S {} + 2> /dev/null | sort | #if want test custom name #2
find "$d" -maxdepth 1 -type f -exec dpkg -S {} + 2> /dev/null | sort |
	while read -r fn; do
		((pgn=gn+1));
		echo "[$pgn/$total] Checking... $fn";
        ((gn++));
        pkgbp="$(echo -n $fn | cut -f2- -d' ' | awk '{$1=$1}1')"; #awk to strip leading path spaces
        if [[ "$(echo $fn | cut -d':' -f1)" =~ $contains_space ]]; then
            echo 'multi-packages not supported.';
        elif [[ "$pkgbp" =~ $contains_space ]]; then
            echo 'multi-packages or path contains space not supported.';
        else 
            pkgp="$pkgn";
            pkgn="$(echo $fn | cut -f1 -d' ')";
            pkgn="$(echo ${pkgn%:})"; #trim trailing :
            pkgn="$(echo ${pkgn%,})"; #trim trailing ,
            pkgb="$(echo $pkgbp | cut -c$dc-)";
            if [ "$pkgp" == "$pkgn" ]; then
                echo -en "\n--- $pkgb" >> "$f";
                ft="$(file -n -b -e elf $pkgbp)";
                if [ "${ft#a }" != "${ft}" ]; then #some files return something like 'a /usr/bin/python script', nid split by ',' for this case.
                    ft="$(echo "$ft" | cut -d',' -f1)"
                else #to reduce noise, all split by space and shows 1st word only.
                    ft="$(echo "$ft" | cut -d' ' -f1)"
                fi;
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
            ft="$(file -n -b -e elf $pkgbp)";
            if [ "${ft#a }" != "${ft}" ]; then
                ft="$(echo "$ft" | cut -d',' -f1)"
            else
                ft="$(echo "$ft" | cut -d' ' -f1)"
            fi;
            echo -e "\t\t($ft)" >> "$f";
            man -f "$pkgb" 2>/dev/null >> "$f";
            if [ "$total" == "$gn" ]; then
                echo -en '\n\n\t\t\t\t' >> "$f";
                dpkg-query -W -f='${Description}\n\n${Homepage}\nMaintainer: ${Maintainer}\n\n' "$pkgn" >>"$f";
                echo >> "$f";
            fi;
        fi;
	done;
if [ ! -f "$f" ]; then
	echo "Sorry, no file has brief";
else echo "Done ... Please check your file $f";
fi
