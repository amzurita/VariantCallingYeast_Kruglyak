#!/bin/bash

#EDIT THIS LINES:
#$ -N TestJoinGenotyping
#$ -o /u/scratch/a/amzurita/logs/out_JoinGenotyping.txt

#$ -j y
#$ -cwd
#$ -M amzurita
#$ -l highp
#$ -l h_data=32G
#$ -l time=24:00:00
#$ -m bea

#Load modules to be used
. /u/local/Modules/default/init/modules.sh
module load anaconda3
module load bwa/0.7.17
module load samtools/1.11
module load gatk/4.2.0.0


#GVCF DB


#SelectVariants


#GenotypeGVCF


#HardFilterVariants


#
