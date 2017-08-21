#!/bin/bash
# Aufruf mit 08_demultiplex_last.sh fastq [Primerfile]


### Variablen
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
PRIMER_FILE_DEFAULT=${SCRIPT_PATH}"/ONBC_96.fa"


if [ -n "$1" ] &&  test -f $1
then
    FASTQ_FILE=$(readlink -f "$1")
    FASTQ_NAME=$(basename "$FASTQ_FILE")
    FASTQ_NAME="${FASTQ_NAME%.*}"
else
    echo "FEHLER: fastq-File nicht gefunden."
    echo "Aufruf mit  $0 fastq-File [Primerfile]"
    exit 1
fi 

if [ -n "$2" ] && test -f $2 
then
    PRIMER_FILE=$(readlink -f "$2")
else
    if test -f $PRIMER_FILE_DEFAULT
    then  
        PRIMER_FILE=$(readlink -f $PRIMER_FILE_DEFAULT)
        echo "Nutze Primerfile $PRIMER_FILE"
    else
        echo "FEHLER: Primer-File nicht gefunden." 
	echo  $PRIMER_FILE_DEFAULT
        echo "Aufruf mit  $0 fastq-File [Primer-File]"
        exit 1  
    fi
fi 

PRIMER_NAME=$(basename "$PRIMER_FILE")
PRIMER_NAME="${PRIMER_NAME%.*}"
OUT_DIR=vlast_${FASTQ_NAME}_${PRIMER_NAME}

echo "SCRIPT_PATH: " ${SCRIPT_PATH}
echo "FASTQ_FILE: " $FASTQ_FILE
echo "PRIMER_FILE: " $PRIMER_FILE
echo "OUT_DIR: " $OUT_DIR


### Demultiplexing mit lastlopper

mkdir -p $OUT_DIR
cd $OUT_DIR
echo ${SCRIPT_PATH}/vlastlopper.pl -p $PRIMER_FILE -i $FASTQ_FILE
${SCRIPT_PATH}/vlastlopper.pl -p $PRIMER_FILE -i $FASTQ_FILE


###Zusammenführung der Reads für Foreward- und Reverse-Barcode
for i in `seq 1 192`;
do
    if [[ -f "./out_lopped/ONBC_$(printf %03d $i)F_clipped.fastq" ]] || [[ -f "./out_lopped/ONBC_$(printf %03d $i)R_clipped.fastq" ]]
    then
        cat "./out_lopped/ONBC_$(printf %03d $i)F_clipped.fastq" "./out_lopped/ONBC_$(printf %03d $i)R_clipped.fastq" > ONBC_$(printf %03d $i)_${FASTQ_NAME}.fastq
    fi    
done   
pwd
ls -la
echo "./out_lopped/"*"bestMapped.tsv"
mv "out_lopped/"*"bestMapped.tsv" .

mv "out_lopped/unknown_clipped.fastq" .
# rm -r "./out_lopped"

# echo "editing sequence names in fastq files"
# for f in *.fastq; do 
#     ${SCRIPT_PATH}/10_paramsInNameSAM.sh $f
# done

cd ..
