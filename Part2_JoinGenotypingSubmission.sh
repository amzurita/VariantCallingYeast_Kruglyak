#!/bin/bash

#EDIT THIS LINES:
#$ -N TestJoinGenotyping
#$ -o /u/scratch/a/amzurita/logs/out_JoinGenotyping.txt

#$ -j y
#$ -cwd
#$ -M amzurita
#$ -l highp
#$ -l h_data=128G
#$ -l time=24:00:00
#$ -m bea

#Load modules to be used
. /u/local/Modules/default/init/modules.sh
module load anaconda3
module load bwa/0.7.17
module load samtools/1.11
module load gatk/4.2.0.0

#EDIT THIS LINES
#output_name should match Part 1
reference=/u/project/kruglyak/amzurita/Data/References/SCER/genome.fa
interval_file=/u/project/kruglyak/amzurita/Data/References/SCER/SCer_IntervalFile.intervals
output_name=TestRun


#GVCF DB
gatk --java-options "-Xmx108g -Xms108g" GenomicsDBImport --genomicsdb-workspace-path ${output_name}_Database -L $interval_file --batch-size 100 --sample-name-map ${output_name}_GVCFs.sample_maps

#SelectVariants


#GenotypeGVCF


#HardFilterVariants


#Filter Genotypes


#Consider adding filtering script


#Collect metrics for the filtering of ploidy ()
