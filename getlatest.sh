if [[ -d "~/grove-base" ]]
then
    cd ~/grove-base
    git pull --ff-only && git clean -fdx
    result=$? 
else
    # no directory, clone it
    result=1
fi

if [ $result -ne 0 ]; then
    # failed to checkout - remove directory and clone fresh
    cd ~
    rm -rf grove-base
    git clone https://github.com/joemarshall/grove-base.git
fi
