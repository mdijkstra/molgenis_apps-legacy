#!/bin/bash
#PBS -N s00_GuestInvitationStep_4
#PBS -q gaf
#PBS -l nodes=1:ppn=1
#PBS -l walltime=20:00:00
#PBS -l mem=4gbgb
#PBS -e s00_GuestInvitationStep_4.err
#PBS -o s00_GuestInvitationStep_4.out
#PBS -W umask=0007



# Configures the GCC bash environment
. /target/gpfs2/gcc/gcc.bashrc

##### BEFORE #####
touch $PBS_O_WORKDIR/s00_GuestInvitationStep_4.out
source /target/gpfs2/gcc/tools/scripts/import.sh
before="$(date +%s)"
echo "Begin job s00_GuestInvitationStep_4 at $(date)" >> $PBS_O_WORKDIR/RUNTIME.log

#echo Running on node: `hostname`

sleep 0
###### MAIN ######
mkdir -p ~/test/compute/helloWorld/results

echo "Hello Adam," > ~/test/compute/helloWorld/results/Adam.txt
echo "We invite you for our wedding." >> ~/test/compute/helloWorld/results/Adam.txt

# Empty footer
