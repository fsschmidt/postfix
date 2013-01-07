#!/bin/sh
# Fabio S. Schmidt <fabio@improve.inf.br>
# 06/Jan/2013
# Contempla excecoes de remetentes que nao terao o disclaimer inserido
# e disclaimers especificos de acordo com o dominio do remetente

# Localize these.
INSPECT_DIR=/var/spool/filter
SENDMAIL=/usr/sbin/sendmail

#REMETENTES QUE NAO DEVEM TER O DISCLAIMER INSERIDO
EXCECOES_REMETENTES=/etc/postfix/excessoes_remetente

#DEFINIMOS QUAL DISCLAIMER DEVE SER INSERIDO PARA CADA DOMINIO
DISCLAIMER1=/etc/postfix/dominios-disclaimer1.txt
DISCLAIMER2=/etc/postfix/dominios-disclaimer2.txt

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
# FAZ A PESQUISA DO DOMINIO REMETENTE PARA ADICIONAR O DISCLAIMER DESEJADO
from_domain=`grep -m 1 "From:" in.$$ | cut -d " " -f 2 | cut -d " " -f 1 | cut -d@ -f2`

#TRATA AS EXCECOES PRIMEIRO
if [ `grep -wi ^${from_address}$ ${EXCECOES_REMETENTES}` ]; then

$SENDMAIL -oi "$@" <in.$$
exit $?

#CONSULTA O DOMINIO DO REMENTE PARA ADICIONAR O DISCLAIMER CORRESPONDENTE
elif  [ `grep -wi ^${from_domain}$ ${DISCLAIMER1}` ]; then
/usr/bin/altermime --input=in.$$ \
                   --disclaimer=/etc/postfix/disclaimer1.txt \
                   --disclaimer-html=/etc/postfix/disclaimer1.html \
                   --xheader="X-Copyrighted-Material: Colocar o site da empresa aqui http://www.company.com/privacy.htm" || \
                     { echo Message content rejected; exit $EX_UNAVAILABLE; }

elif  [ `grep -wi ^${from_domain}$ ${DISCLAIMER2}` ]; then

/usr/bin/altermime --input=in.$$ \
                   --disclaimer=/etc/postfix/disclaimer2.txt \
                   --disclaimer-html=/etc/postfix/disclaimer2.html \
                   --xheader="X-Copyrighted-Material: Colocar o site da empresa aqui http://www.company.com/privacy.htm" || \
                     { echo Message content rejected; exit $EX_UNAVAILABLE; }

fi

### ENVIA A MENSAGEM APOS INSERIR O DISCLAIMER DESEJADO ###
$SENDMAIL -oi "$@" <in.$$
exit $?
