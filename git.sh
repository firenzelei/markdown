wget -O ~/.git-completion.bash https://raw.githubusercontent.com/git/git/3bc53220cb2dcf709f7a027a3f526befd021d858/contrib/completion/git-completion.bash 
echo "source ~/.git-completion.bash" >> ~/.bashrc
source ~/.git-completion.bash

git config --global alias.st status
git config --global alias.br branch
git config --global alias.cm commit
