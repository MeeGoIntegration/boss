#!/bin/bash


function get-git-repos() {
    while read dir
    do
	read url
	if [ -d "$dir" ] ; then
	    echo Updating $dir
	    (cd $dir; git pull)
	else
	    url=${url#*URL: }
	    echo cloning $dir from $url
	    git clone $url
	fi
    done
}



cat <<EOF | get-git-repos
daemon-kit
  Fetch URL: git://github.com/kennethkalmer/daemon-kit.git
ruote
  Fetch URL: git://github.com/jmettraux/ruote.git
ruote-amqp
  Fetch URL: git://github.com/kennethkalmer/ruote-amqp.git
ruote-fluo
  Fetch URL: git://github.com/jmettraux/ruote-fluo.git
ruote-kit
  Fetch URL: git://github.com/kennethkalmer/ruote-kit.git
ruote-web
  Fetch URL: git://github.com/jmettraux/ruote-web.git
EOF
