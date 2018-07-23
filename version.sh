git ls-remote --refs --tags https://github.com/phpvirtualbox/phpvirtualbox.git | sort -t '/' -k 3 -V | awk -F/ '{ print $3 }' | tail -1
