#!/bin/sh
INSPECT_DIR=/var/spool/filter
SENDMAIL=/usr/sbin/sendmail

# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

# Clean up when done or when aborting.
trap “rm -f in.$$” 0 1 2 3 15

# Start processing.
cd $INSPECT_DIR || { echo $INSPECT_DIR does not exist; exit
$EX_TEMPFAIL; }

cat >in.$$ || { echo Cannot save mail to file; exit $EX_TEMPFAIL; }

#criar o arquivo default.txt com o disclaimer em modo texto e o arquivo disclaimer.html
#com o conteudo que sera adicionado em mensagens com formato html

/usr/bin/altermime –input=in.$$ \
  –disclaimer=/etc/postfix/disclaimer/default.txt \
                   –disclaimer-html=/etc/postfix/default.html \
                   –xheader=”X-Copyrighted-Material: Colocar site da empresa aqui http://www.company.com/privacy.htm&#8221; || \
{ echo Message content rejected; exit $EX_UNAVAILABLE; }

$SENDMAIL -oi “$@” <in.$$

exit $?
