#!/bin/sh

# exit when any error
set -e

link_sh() {
  local old_name="$1"
  local new_name="$2"

  echo "$old_name -> $new_name"
  ln -s "$old_name" "$new_name"
  chmod a+x "$new_name"
}

for file in /scripts/*.sh
do
    if [[ -f $file ]]; then
        bname=$(basename "$file")
        link_sh "$file" "/bin/${bname%.*}"
    fi
done
