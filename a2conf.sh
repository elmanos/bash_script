#!/bin/bash
## Autor: Diego Fernández Doce
## Descripción: Automatización de creación de carpeta Web en /var/www
## 		los archivos de configuración de hosts y sites-availabe y sites-enable
##		y reinicio del servidor.

####################
## Configuración ##
###################
SITES_AVAILABLE_PATH="/etc/apache2/sites-available/"
SITES_ENABLED_PATH="/etc/apache2/sites-enabled/"
HOSTS_PATH="/etc/hosts"
WWW_PATH="/var/www/"

# Text color variables
txtred='\e[0;31m'       # red
txtgrn='\e[0;32m'       # green
txtylw='\e[0;33m'       # yellow
txtblu='\e[0;34m'       # blue
txtpur='\e[0;35m'       # purple
txtcyn='\e[0;36m'       # cyan
txtwht='\e[0;37m'       # white
bldred='\e[1;31m'       # red    - Bold
bldgrn='\e[1;32m'       # green
bldylw='\e[1;33m'       # yellow
bldblu='\e[1;34m'       # blue
bldpur='\e[1;35m'       # purple
bldcyn='\e[1;36m'       # cyan
bldwht='\e[1;37m'       # white
txtund=$(tput sgr 0 1)  # Underline
txtbld=$(tput bold)     # Bold
txtrst='\e[0m'          # Text reset

info=${bldwht}*${txtrst}
pass=${bldblu}*${txtrst}
warn=${bldred}!${txtrst}


# Indicator usage
#echo -e "${info}"
#echo -e "${pass}" 
#echo -e "${warn}"

########################
## Mostramos la ayuda ##
########################
function show_help() { 

	if [ "$1" == "-h" ]; then
		echo -e "${info} ${bldwht}Uso: `basename $0` [dominio de la Web] Ej:${txtrst} ${info} ${bldblu} bash `basename $0` esteesmidominio.com ${txtrst}"
		exit 0
	elif [ -z $1 ]; then
                echo -e "${info} ${bldwht}Uso: `basename $0` [dominio de la Web] Ej:${txtrst} ${info} ${bldblu} bash `basename $0` esteesmidominio.com ${txtrst}"
                exit 0
	fi
	
}

show_help $1

###########################
## Creamos el directorio ##
###########################

function create_directory() {
	if [ -d "$WWW_PATH$1" ]; then
		echo -e "${warn} ${bldred} [Error] Paso 1: La carpeta /var/www/$1 ya está creada.${txtrst} ${warn}"
	else
		mkdir $WWW_PATH$1
		echo -e "${info} ${bldwht}Paso 1: La carpeta /var/www/$1 ha sido creada.${txtrst} ${info}"
	fi
}


######################
## Añadimos el host ##
######################

function add_host() {
	sudo echo "127.0.0.1 $1.local" >> $HOSTS_PATH
	echo -e "${info} ${bldwht} Paso 2: Creado $1.local en $HOSTS_PATH ${txtrst} ${info}"
}


########################
## ##
#######################

function sites_available() {


	if [ -f "$SITES_AVAILABLE_PATH$1.conf" ]; then
		echo -e "${warn} ${bldred} [Error] Paso 3: El archivo ya existe. ${txtrst} ${warn}"
	else
		sudo touch $SITES_AVAILABLE_PATH$1.conf
		sudo echo "<VirtualHost *:80>" >> $SITES_AVAILABLE_PATH$1.conf
		sudo echo "        DocumentRoot /var/www/$1" >> $SITES_AVAILABLE_PATH$1.conf
		sudo echo "        ServerName $1.local" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "        <Directory /var/www/$1/>" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "               AllowOverride All" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "                Options FollowSymLinks" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "                DirectoryIndex index.php" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "                Order allow,deny" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "                Allow from all" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "                AllowOverride All" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "                Options FollowSymLinks" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "        </Directory>" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo " " >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "        LogLevel warn" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "        CustomLog \${APACHE_LOG_DIR}/$1_access.log combined" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "        ErrorLog \${APACHE_LOG_DIR}/$1_error.log" >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo " " >> $SITES_AVAILABLE_PATH$1.conf
                sudo echo "</VirtualHost>" >> $SITES_AVAILABLE_PATH$1.conf
		
		echo -e "${info} ${bldwht} Paso3: Añadiendo contenido al archivo $SITES_AVAILABLE_PATH$1.conf ${txtrst} ${info}"

	fi

	if [ -L "$SITES_ENABLED_PATH$1.conf" ]; then
		echo -e "${warn} ${bldred} [Error] Paso4: El link ya existe en sites-enabled. ${txtrst} ${warn}"
	else
		ln -s $SITES_AVAILABLE_PATH$1.conf $SITES_ENABLED_PATH$1.conf
		echo -e "${info} ${bldwht} Paso4: Creado el link /etc/apache2/sites-enabled/$1.conf ${txtrst} ${info}"
	fi

}


##########
## Main ##
##########

show_help $1
create_directory $1
add_host $1
sites_available $1
sudo service apache2 reload


