set -x 
set -e


PHP_SERVICE=wp-php

DOC_ROOT="/var/www/html/$1" 

shift

echo $DOC_ROOT

echo $@


docker exec -u 1000:1000 -i $PHP_SERVICE sh <<EOF
 set -e
 cd $DOC_ROOT
 wp $@
EOF
