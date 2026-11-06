#!/bin/bash

############################################################
# Help                                                     #
############################################################

set -e 
set -x
Help()
{
 
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "g     Print the GPL license notification."
   echo "h     Print this Help."
   echo "v     Verbose mode."
   echo "V     Print software version and exit."
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

DOMAIN_NAME="${!#}"

while getopts ':hv:-:' opt; do 
    if [ "$opt" = '-' ]; then 
      case "$OPTARG" in 
         help) 
            opt=h 
            ;;
         version=*)
            opt=v 
            OPTARG=${OPTARG#*=} # Extracts value after =
            ;;
         *) 
            echo 'unknown option' 
            ;;
      esac      
    fi

    case $opt in 
        h)
            Help
            ;;
        v)  
            VERSION="$OPTARG" 
            echo "Version: $VERSION" # Prints the version output
            ;;
        *)
            echo 'unknown option'
            ;;
    esac
done


docker compose up -d

PHP_SERVICE=wp-php
MYSQL_SERVICE=wp-mariadb
NGINX_SERVICE=wp-nginx
DB_ROOT_USER=root
DB_ROOT_PASS=hguyFtgfR4r9R4r76




docker exec -i $MYSQL_SERVICE sh << EOF
	set -e 
	set -x
	mysql -u root -phguyFtgfR4r9R4r76 -e "DROP DATABASE IF EXISTS \\\`${DOMAIN_NAME}\\\`"	
	mysql -u root -phguyFtgfR4r9R4r76 -e "CREATE DATABASE \\\`${DOMAIN_NAME}\\\`"
EOF


if [[ -z ${VERSION} ]] 
then
	VERSION='latest'
fi

DOC_ROOT="/var/www/html/${DOMAIN_NAME}"

docker exec -i "$PHP_SERVICE" sh << EOF
	
	set -e 
	if [[ -d ${DOC_ROOT} ]]; then
	
		#read -r "${DOC_ROOT} already exists Delete it?" USER_RES
		#if [[ "${USER_RES}" == "yes" ]]
		#then 
		rm -rf $DOC_ROOT
		#fi
		mkdir -p ${DOC_ROOT} 
	else 
		 mkdir -p ${DOC_ROOT}  
	fi
	cd ${DOC_ROOT}
	wp core download --version=${VERSION} --allow-root --force
	wp config create --force --dbname=${DOMAIN_NAME} --dbuser=$DB_ROOT_USER --dbpass=$DB_ROOT_PASS --dbhost=${MYSQL_SERVICE} --allow-root
	wp core install \
		--url="http://${DOMAIN_NAME}" \
		--title="Dummy Test Site" \
		--admin_user="admin" \
		--admin_password="password" \
		--admin_email="dummy@example.com" \
		--allow-root
	chown -R 1000:1000 ${DOC_ROOT}
EOF


docker exec -i  "${NGINX_SERVICE}" sh << EOF
       set -e 
	   
		cat << VHOST  >  "/etc/nginx/conf.d/${DOMAIN_NAME}.conf"
				server  {
					listen 80;
					server_name ${DOMAIN_NAME};
					root ${DOC_ROOT};
					location / {
						index index.php;
						try_files \\\$uri \\\$uri/ /index.php?\\\$args;
					}
					location ~ \.php$ {
					fastcgi_pass   wp-php:9000;
					fastcgi_index  index.php;
					fastcgi_param  SCRIPT_FILENAME \\\$document_root\\\$fastcgi_script_name;
					include        fastcgi_params;
					}	
				}
VHOST
	chown 1000:1000 "/etc/nginx/conf.d/${DOMAIN_NAME}.conf"
	nginx -s reload 
EOF