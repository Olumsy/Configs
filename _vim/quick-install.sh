#!/bin/bash

: "${MYVIMRC:=$HOME/.vimrc}"

FILE="$MYVIMRC"
LOCAL_PATH="$PWD"
 
if grep -Fxq "source $LOCAL_PATH/srcs_loader.vim" "$FILE"; then
    echo "Already implemented in \"$FILE\"."
else
    echo "source $LOCAL_PATH/srcs_loader.vim" >> "$FILE"
    echo "Now implemented in \"$FILE\"."
fi

echo "You can now enable/disable features in \"$LOCAL_PATH/srcs_loader.vim\" by uncommenting/commenting."
