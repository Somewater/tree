ssh -t root@hellespontus.com "cd tree && \
git pull && \
exit"
scp bin-debug/*.swf root@hellespontus.com:~/tree/bin-debug
echo "Succesfully deployed"
