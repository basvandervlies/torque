#!/bin/sh
#
# Author: Bas van der Vlies
# Desc. : The tcl gui commands uses the wrong settings for
#         libdir, appdefdir and the interperter
# 
# SVN Info:
#	$Id: patch_gui_cmds.sh 365 2004-03-18 10:57:22Z bas $
#

for file in xpbs xpbsmon
do
	sed -e "s,set libdir.*,set libdir $1/$file," \
    	 -e "s,set appdefdir.*,set appdefdir $1/$file," \
    	 `pwd`/debian/tmp/usr/bin/$file > ./tmp$$

	mv ./tmp$$ `pwd`/debian/tmp/usr/bin/$file
	chmod 755 `pwd`/debian/tmp/usr/bin/$file
done

# xpbsmon has also wrong interperter
#
sed -e "s,.*/usr/bin/pbs_wish.*,#!/usr/bin/pbs_wish -f," \
 `pwd`/debian/tmp/usr/bin/xpbsmon > ./tmp$$

mv ./tmp$$ `pwd`/debian/tmp/usr/bin/xpbsmon
chmod 755 `pwd`/debian/tmp/usr/bin/xpbsmon
