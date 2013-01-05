#!/bin/sh
# Fabio S. Schmidt <fabio@improve.inf.br>
# 05/Jan/2013
# Contempla exceções de remetentes que não terão o disclaimer inserido
# Inserir os remetentes para exceção no arquivo definido pela variavel EXCESSOES_REMETENTES

# Localize these.
INSPECT_DIR=/var/spool/filter
SENDMAIL=/usr/sbin/sendmail

#REMETENTES QUE NAO DEVEM TER O DISCLAIMER INSERIDO
EXCECOES_REMETENTES=/etc/postfix/excecoes_remetente

# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

# Clean up when done or when aborting.
trap "rm -f in.$$" 0 1 2 3 15

# Start processing.
cd $INSPECT_DIR || { echo $INSPECT_DIR does not exist; exit
$EX_TEMPFAIL; }

cat >in.$$ || { echo Cannot save mail to file; exit $EX_TEMPFAIL; }

#FAZ A PESQUISA DO REMETENTE PARA A EXCECAO
from_address=`grep -m 1 "From:" in.$$ | cut -d " " -f 2 | cut -d " " -f 1`


if [ `grep -wi ^${from_address}$ ${EXCECOES_REMETENTES}` ]; then

$SENDMAIL -oi "$@" <in.$$
exit $?

else

/usr/bin/altermime --input=in.$$ \
                   --disclaimer=/etc/postfix/disclaimer.txt \
                   --disclaimer-html=/etc/postfix/disclaimer.html \
                   --xheader="X-Copyrighted-Material: Colocar o site da empresa aqui http://www.company.com/privacy.htm" || \
                     { echo Message content rejected; exit $EX_UNAVAILABLE; }
$SENDMAIL -oi "$@" <in.$$
exit $?

fi
