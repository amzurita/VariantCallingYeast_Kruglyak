#!/bin/bash

#EDIT THIS LINES:
#$ -N TestVariantCalling
#$ -o /u/scratch/a/amzurita/logs/out_TestVariantCalling_$JOB_ID.$TASK_ID.txt

#$ -j y
#$ -cwd
#$ -M amzurita
#$ -l highp
#$ -l h_data=32G
#$ -l time=24:00:00
#$ -m bea

#EDIT THIS LINE WITH THE NUMBER OF SAMPLES (See the trick at the end of the script to count)
#$ -t 1-8

. /u/local/Modules/default/init/modules.sh
module load anaconda3

#EDIT THIS LINES
#Specifying Inputs. First is metafile, second is the tree building database, third is the outgroup name and fourth is the SH number threshold.
metafile=/u/project/kruglyak/amzurita/Data/VariantCalling/TestRun/list_fastas_forTesting.txt
reference=/u/project/kruglyak/amzurita/Data/References/SCER/genome.fa
output_name=TestRun

#Parsing a metadata file:
# metafile=variable, path to a text file. Each sample is a line, and each variable in each line is tab separated (each column is tab separated)
myline=$(sed -n "${SGE_TASK_ID}"p ${metafile})
read -ra INFO <<<"$myline"

#Each variable can be extracted by calling INFO[colnumber], where the columns are 0 indexed.
sampleid=${INFO[0]}
foward_reads=${INFO[1]}
reverse_reads=${INFO[2]}

echo "Job $JOB_ID.$SGE_TASK_ID on sample $sampleid"

#Call the script
/u/project/kruglyak/amzurita/Scripts/VariantCalling/Part1_HaplotypeCallerTask.sh $sampleid $foward_reads $reverse_reads $reference

#Add the output to a metadata file for the GVCF paths
new_line="${sampleid}\t${sampleid}.g.vcf.gz"

if [ $SGE_TASK_ID == 1 ]; then
  echo -e $new_line > ${output_name}_GVCFs.sample_map
  touch ${output_name}_SamplesFailed.txt
else
  echo -e $new_line >> ${output_name}_GVCFs.sample_map
fi


# Save the ones that failed by checking if the file exists into _SamplesFailed.txt
if ! [ -e ${sampleid}.g.vcf.gz] ; then
  echo -e $sampleid >> ${output_name}_SamplesFailed.txt
fi

#Example task array command:
# -t: the script that you're running is a task array, not a regular script.
#1-N: replace N with the number of samples in your task array (aka. the number of lines in the metadata file)
# You can replace N with $(cat metafile.txt | wc -l) to automatize
# -cwd: Use the current working

#N=$(cat metafile.txt | wc -l)
#qsub -t 1-$N -cwd example_task_array_script.sh pathtometadtata/file.txt 50
