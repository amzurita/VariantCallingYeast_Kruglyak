#!/bin/bash
#set -e
#set -u
#set -o pipefail

#Load modules to be used
. /u/local/Modules/default/init/modules.sh
module load anaconda3
module load bwa/0.7.17
module load samtools/1.11
module load gatk/4.2.0.0

#Read the inputs, which consist of:(1)Sample ID, (2)Foward Reads in a FASTQ, (3)Reverse Reads in a FASTQ, (4)Reference file (5) Optional ploidy argument. 2 by default.
sample_id=$1
f_reads=$2
r_reads=$3
reference_fa=$4
ploidy=${5:-2}

#QC_Step (FUTURE)

#GATK for FastaTouBAM
gatk FastqToSam -F1 $f_reads -F2 $r_reads -O delete_${sample_id}_unaligned.bam -SM $sample_id -RG FLOWCELL_${sample_id} -PL ILLUMINA

#MarkIlluminaAdapters
gatk MarkIlluminaAdapters -I delete_${sample_id}_unaligned.bam -O delete_${sample_id}_markilluminaadapters.bam -M ${sample_id}_markilluminaadapters_metrics.txt

#Generate FASTQ
gatk SamToFastq -I delete_${sample_id}_markilluminaadapters.bam --FASTQ delete_${sample_id}_singlefastq.fastq -CLIP_ATTR XT -CLIP_ACT 2 -INTER true -NON_PF true

#Aligment
bwa mem -M -R "@RG\\tID:FLOWCELL_${sample_id}\\tSM:${sample_id}\\tPL:ILLUMINA" -p $reference_fa delete_${sample_id}_singlefastq.fastq | samtools view -1 -o delete_${sample_id}_aligned.bam
#Consider adding the -t ${task.cpus} in the future

gatk MergeBamAlignment -ALIGNED delete_${sample_id}_aligned.bam -UNMAPPED delete_${sample_id}_markilluminaadapters.bam -O delete_${sample_id}.sorted.bam -R $reference_fa

#Mark duplicates
gatk MarkDuplicates -I delete_${sample_id}.sorted.bam -O delete_${sample_id}.marked_duplicates.bam -M ${sample_id}.marked_duplicates.metrics

#ReorderSAM
gatk ReorderSam -I delete_${sample_id}.marked_duplicates.bam -O ${sample_id}.reordered.bam -SD $reference_fa

#BuildBAMIndex
gatk BuildBamIndex -I ${sample_id}.reordered.bam

#ADD QC Steps: Alignment Metrics & Insert Size Metrics
# java -jar picard.jar \
#         CollectAlignmentSummaryMetrics \
#         R=ref.fa \
#         I=sorted_dedup_reads.bam \
#         O=alignment_metrics.txt
#
# java -jar picard.jar \
# CollectInsertSizeMetrics \
#         INPUT=sorted_dedup_reads.bam \
#         OUTPUT=insert_metrics.txt \
#         HISTOGRAM_FILE=insert_size_histogram.pdf
#
# samtools depth -a sorted_dedup_reads.bam > depth_out.txt

#HaplotypeCaller
gatk HaplotypeCaller -R $reference_fa -I ${sample_id}.reordered.bam -O ${sample_id}.g.vcf.gz -ERC GVCF -ploidy $ploidy

#Add step to delete intermediate files
#rm delete_*
