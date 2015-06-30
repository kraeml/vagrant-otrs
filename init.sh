VERSION='4.0.9' # OTRS
MYSQL_PASSWORD='vagrant'

install_mysql () {
	debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
	debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
	apt-get install mysql-server -y > /dev/null
}

install_apache () {
	sudo apt-get install -y apache2 build-essential libapache-dbi-perl libapache2-mod-perl2 libapache2-mod-perl2 libarchive-zip-perl libarchive-zip-perl libcrypt-eksblowfish-perl libdbd-mysql-perl libdbd-mysql-perl libdbd-mysql-perl libdbi-perl libdigest-md5-file-perl libdigest-perl libgd-graph-perl libgd-text-perl libio-socket-ssl-perl libjson-xs-perl libjson-xs-perl libnet-dns-perl libnet-dns-perl libnet-ldap-perl libpdf-api2-perl libsoap-lite-perl libtemplate-perl libtemplate-perl libtext-csv-xs-perl libtext-csv-xs-perl libtimedate-perl libxml-parser-perl libyaml-libyaml-perl libyaml-libyaml-perl perl > /dev/null
}

install_otrs_dependencies () {
	sudo apt-get install -y libencode-hanextra-perl libgd-gd2-perl 
}

install_phpmyadmin () {
	# taken from mauserrifle/vagrant-debian-shell
	if [ ! -f /etc/phpmyadmin/config.inc.php ];
	then

		# Used debconf-get-selections to find out what questions will be asked
		# This command needs debconf-utils

		# Handy for debugging. clear answers phpmyadmin: echo PURGE | debconf-communicate phpmyadmin

		echo 'phpmyadmin phpmyadmin/dbconfig-install boolean false' | debconf-set-selections
		echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

		echo "phpmyadmin phpmyadmin/app-password-confirm password $MYSQL_PASSWORD" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_PASSWORD" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/password-confirm password $MYSQL_PASSWORD" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/setup-password password $MYSQL_PASSWORD" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/database-type select mysql" | debconf-set-selections
		echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_PASSWORD" | debconf-set-selections
		
		echo "dbconfig-common dbconfig-common/mysql/app-pass password $MYSQL_PASSWORD" | debconf-set-selections
		echo "dbconfig-common dbconfig-common/mysql/app-pass password" | debconf-set-selections
		echo "dbconfig-common dbconfig-common/password-confirm password $MYSQL_PASSWORD" | debconf-set-selections
		echo "dbconfig-common dbconfig-common/app-password-confirm password $MYSQL_PASSWORD" | debconf-set-selections
		echo "dbconfig-common dbconfig-common/app-password-confirm password $MYSQL_PASSWORD" | debconf-set-selections
		echo "dbconfig-common dbconfig-common/password-confirm password $MYSQL_PASSWORD" | debconf-set-selections
	fi
	
	apt-get -y install phpmyadmin
}

install_otrs () {
	echo "Download otrs..."
	wget -q "http://ftp.otrs.org/pub/otrs/otrs-$VERSION.tar.bz2" > /dev/null
	echo "Extract otrs..."
	tar xjf otrs-$VERSION.tar.bz2 > /dev/null
	sudo mv otrs-$VERSION /opt/otrs

	echo "Add otrs user..."
	sudo useradd -d /opt/otrs/ -c 'OTRS user' otrs
	sudo usermod -G www-data otrs
	# Use `sudo usermod -Ga www-data otrs` instead when installing on an existing system

	cd /opt/otrs/
	cp Kernel/Config.pm.dist Kernel/Config.pm
	cp Kernel/Config/GenericAgent.pm.dist Kernel/Config/GenericAgent.pm
	echo "Check perl dependencies"
	sudo perl /opt/otrs/bin/otrs.CheckModules.pl
	sudo perl -cw /opt/otrs/bin/cgi-bin/index.pl
	sudo perl -cw /opt/otrs/bin/cgi-bin/customer.pl
	sudo perl -cw /opt/otrs/bin/otrs.PostMaster.pl
	bin/otrs.SetPermissions.pl --web-group=www-data
	sudo cp /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/otrs.conf
	sudo a2ensite otrs
	# Do we need to do that too?
	# a2enmod perl
	# a2dismod mpm_event
	# a2enmod mpm_prefork
	sudo service apache2 restart
}

echo "apt-get update..."
sudo apt-get update > /dev/null
echo "apt-get install..."
install_mysql
install_otrs_dependencies
install_apache
install_otrs
install_phpmyadmin

