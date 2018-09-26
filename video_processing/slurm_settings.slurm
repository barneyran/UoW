#!/bin/bash 
# This is for SLURM 
#SBATCH -o result.out
#SBATCH -e result.error
#SBATCH --job-name=set05
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=1

# This will set the right modules
module rm gcc/5.2.0
module load gcc/4.9.4
module load matlab/2017a 

# Change into the current working directory
cd $PWD 

# This is for Matlab
matlab -nodesktop -nosplash -r "main(); exit"

# End of Script