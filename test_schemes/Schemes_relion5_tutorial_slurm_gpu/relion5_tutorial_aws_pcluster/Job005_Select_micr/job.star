
# version 30001

data_job

_rlnJobTypeLabel             relion.select.split
_rlnJobIsContinue                       0
_rlnJobIsTomo                           0
 

# version 30001

data_joboptions_values

loop_ 
_rlnJobOptionVariable #1 
_rlnJobOptionValue #2 
dendrogram_minclass      -1000 
dendrogram_threshold       0.85 
discard_label rlnImageName 
discard_sigma          4 
do_class_ranker         No 
do_discard         No 
do_filaments         No 
  do_queue         No 
 do_random         No 
do_recenter        Yes 
do_regroup         No 
do_remove_duplicates         No 
do_select_values         No 
  do_split        Yes 
duplicate_threshold         30 
   fn_data         "" 
    fn_mic CtfFind/job003/micrographs_ctf.star 
  fn_model         "" 
image_angpix         -1 
min_dedicated          0 
 nr_groups          1 
  nr_split         -1 
other_args         "" 
      qsub JSE_DISABLED_PARALLEL 
qsub_extra1 JSE_DISABLED_PARALLEL 
qsub_extra2          0 
qsubscript JSE_DISABLED_PARALLEL 
 queuename Job005_Select 
rank_threshold        0.5 
select_label rlnCtfMaxResolution 
select_maxval      9999. 
select_minval     -9999. 
select_nr_classes         -1 
select_nr_parts         -1 
split_size         10 
 
