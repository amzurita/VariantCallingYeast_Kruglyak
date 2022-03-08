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
gatk --java-options "-Xmx108g -Xms108g" GenomicsDBImport --genomicsdb-workspace-path Database_${output_name} -L $interval_file --batch-size 50 --sample-name-map ${output_name}_GVCFs.sample_maps

#GenotypeGVCF
gatk --java-options "-Xmx108g -Xms108g" GenotypeGVCFs -R $reference -V gendb://Database_${output_name} -O delete_${output_name}_combinedGVCFs.vcf.gz

# #Filter SNP
# gatk --java-options "-Xmx108g -Xms108g" SelectVariants -V delete_${output_name}_combinedGVCFs.vcf.gz -R $reference -select-type SNP -O delete_${output_name}_snps.vcf.gz
#
# gatk --java-options "-Xmx108g -Xms108g" VariantFiltration -V delete_${output_name}_snps.vcf.gz -R $reference \
# -filter "QD < 20.0" --filter-name "QD20" -filter "QUAL < 30.0" --filter-name "QUAL30" \
# -filter "SOR > 3.0" --filter-name "SOR3" -filter "FS > 60.0" --filter-name "FS60" \
# -filter "MQ < 40.0" --filter-name "MQ40" \
# -O delete_${output_name}_snps_filtered.vcf.gz
#
# #Filter indels
# gatk --java-options "-Xmx108g -Xms108g" SelectVariants -V delete_${output_name}_combinedGVCFs.vcf.gz -R $reference -select-type INDEL -O delete_${output_name}_indels.vcf.gz
#
# gatk --java-options "-Xmx108g -Xms108g" VariantFiltration -V delete_${output_name}_indels.vcf.gz -R $reference \
# -filter "QD < 20.0" --filter-name "QD20" -filter "QUAL < 30.0" --filter-name "QUAL30" \
# -filter "FS > 200.0" --filter-name "FS200" -O delete_${output_name}_indels_filtered.vcf.gz
#
# #Join Filtered Genotypes
# gatk --java-options "-Xmx108g -Xms108g" MergeVcfs -R $reference -I delete_${output_name}_snps_filtered.vcf.gz -I delete_${output_name}_indels_filtered.vcf.gz -O ${output_name}.filteredcalls.vcf.gz

#Consider adding filtering script


#Collect metrics for the filtering of ploidy
#Edit this line when filters are applied
gatk --java-options "-Xmx108g -Xms108g" VariantsToTable -V delete_${output_name}_combinedGVCFs.vcf.gz -F CHROM -F POS -F TYPE -F REF -F ALT -F MULTI-ALLELIC -GF GT -GF DP -GF AD -O output.table
