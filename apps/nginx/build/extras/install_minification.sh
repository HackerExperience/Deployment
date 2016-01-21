MODULES_PATH=/root/nginx
cd $MODULES_PATH
wget http://www.cpan.org/authors/id/L/LE/LEEJO/Regexp-RegGrp-2.00.tar.gz
tar zxpfv Regexp-RegGrp-2.00.tar.gz
cd Regexp-RegGrp-2.00
perl Makefile.PL && make && make install

cd $MODULES_PATH
wget http://cpan.metacpan.org/authors/id/G/GT/GTERMARS/JavaScript-Minifier-XS-0.11.tar.gz
tar zxpfv JavaScript-Minifier-XS-0.11.tar.gz
cd JavaScript-Minifier-XS-0.11
perl Makefile.PL && make && make install

cd $MODULES_PATH
wget http://cpan.metacpan.org/authors/id/G/GT/GTERMARS/CSS-Minifier-XS-0.09.tar.gz
tar zxpfv CSS-Minifier-XS-0.09.tar.gz
cd CSS-Minifier-XS-0.09
perl Makefile.PL && make && make install

cd $MODULES_PATH
wget http://cpan.metacpan.org/authors/id/N/NE/NEVESENIN/HTML-Packer-1.004001.tar.gz
tar zxpfv HTML-Packer-1.004001.tar.gz
cd HTML-Packer-1.004001
perl Makefile.PL && make && make install

mkdir /etc/nginx/perl 
cd /etc/nginx/perl/
wget https://raw.githubusercontent.com/nginx-modules/nginx-minify/master/perl/Minify.pm
