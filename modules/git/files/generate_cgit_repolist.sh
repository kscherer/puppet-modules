#!/bin/bash

#!/bin/bash

print_gitdir() {
    for dir in $1;
    do
        if [ -f "$dir/HEAD" ]; then
            echo "repo.url=${dir:5}"
            echo "repo.path=$dir"
            echo
        fi
    done
}

#Find all repos in /git/, but exclude less useful ones to be added in sections at the end
base_repos=$(find -L /git/ \( -name objects -o -name hooks -o -name refs -o -name branches -o -name info -o -name logs -o -path /git/projects -o -path /git/toolchain -o -path /git/users -o -path /git/external -o -path /git/managed_builds \) -prune -o -type d -print )
print_gitdir "$base_repos"

echo "section=1-Projects --------------------------"
project_repos=$(find -L /git/projects/ \( -name objects -o -name hooks -o -name refs -o -name branches -o -name info -o -path /git/projects/cgcs -o -path /git/projects/nx-\* -o -path /git/projects/wraxl -o -path /git/projects/pfi-3.0/wrll-pfi \) -prune -o -type d -print )
print_gitdir "$project_repos"

echo "section=2-Users -----------------------------------"
user_repos=$(find -L /git/users/ -maxdepth 2 \( -name objects -o -name hooks -o -name refs -o -name branches -o -name info -o -name .git \) -prune -o -type d -print )
print_gitdir "$user_repos"

echo "section=3-Toolchain ----------------------------"
toolchain_repos=$(find -L /git/toolchain \( -name objects -o -name hooks -o -name refs -o -name branches -o -name info \) -prune -o -type d -print )
print_gitdir "$toolchain_repos"

echo "section=4-External -----------------------------"
external_repos=$(find -L /git/external \( -name objects -o -name hooks -o -name refs -o -name branches -o -name info \) -prune -o -type d -print )
print_gitdir "$external_repos"
