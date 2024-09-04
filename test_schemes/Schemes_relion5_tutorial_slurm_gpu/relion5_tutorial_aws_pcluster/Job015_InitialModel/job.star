
# version 30001

data_job

_rlnJobTypeLabel             relion.initialmodel
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
ctf_intact_first_peak         No 
do_combine_thru_disc         No 
do_ctf_correction        Yes 
do_parallel_discio        Yes 
do_preread_images         No 
  do_queue        Yes 
 do_run_C1        Yes 
do_solvent        Yes 
   fn_cont         "" 
    fn_img Select/job014/particles.star 
   gpu_ids    0,1,2,3 
min_dedicated          1 
nr_classes          1 
   nr_iter        100 
    nr_mpi          1 
   nr_pool         30 
nr_threads          4 
other_args         "" 
particle_diameter        200 
      qsub     sbatch 
qsub_extra1 g4dn-vcpu48-gpu4 
qsub_extra2          1 
qsubscript /efs/em/aws_slurm_relion_excl.sh 
 queuename Job015_InitialModel 
scratch_dir   /scratch 
  sym_name         D2 
 tau_fudge          4 
   use_gpu        Yes 
 
