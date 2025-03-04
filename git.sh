R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
ls_cmd=$(find . -maxdepth 1 -type d ! -name ".")
# ls_cmd=$(ls -d *)
git_push_repo() {
    for i in $ls_cmd ; do
        cd "$i" || continue

        if [ -d .git ]; then
            echo -e "on $G $i $N .git repo exist...$G pusing the code to remote repo $N"
            git add . ; git commit -m "auto commit" ; git push
            cd ..
            continue
        else n
            echo -e "on $R $i $N .git repo not exist...$Y Skipping the $i $N"
            cd ..
            continue
        fi
    done
}
git_push_repo

