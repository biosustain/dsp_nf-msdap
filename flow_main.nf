#!/usr/bin/env nextflow

params.outdir = "results"
//experiment = "$projectDir/data/${params.file}"
//groups_file = "$projectDir/data/${params.groups}"

log.info """
              M S - D A P  W R A P P E R
          ==================================
          github.com/biosustain/dsp_nf-msdap
          ----------------------------------
          MS format  : ${params.format}
          experiment : ${params.file}
          library    : ${params.library}
          force      : ${params.force_download}
          organism   : ${params.taxid}
          groups     : ${params.groups}
          """

process getFasta {
  container 'pandas/pandas:pip-all'
  output:
    path "${params.library}/*.fasta.gz"
  script:
  """
  get_conversion_table.py --proteomes ${params.library} --force ${params.force_download} --taxid ${params.taxid}
  """
}

process generateSamples {
  container 'albsantosdel/test-msdap:argparse'
  input:
    path experiment
  output:
    path 'samples.xlsx'
  script:
  """
  dataMakeReportTemplate_1.R --filenamepath $experiment \
  --format ${params.format} \
  --confidence_threshold ${params.confidence_threshold} \
--use_normalized_intensities ${params.use_normalized_intensities} \
--use_irt ${params.use_irt} \
--return_decoys ${params.return_decoys} \
--remove_shared_spectronaut_proteingroups ${params.remove_shared_spectronaut_proteingroups} \
--do_plot ${params.do_plot} \
--remove_lowconf ${params.remove_lowconf} \
--one_psm_per_precursor ${params.one_psm_per_precursor} \
--collapse_peptide_by ${params.collapse_peptide_by} \
--filter_min_detect ${params.filter_min_detect} \
--filter_min_quant ${params.filter_min_quant} \
--filter_fraction_detect ${params.filter_fraction_detect} \
--filter_fraction_quant ${params.filter_fraction_quant} \
--filter_by_contrast ${params.filter_by_contrast} \
--norm_algorithm.vsn ${params.norm_algorithm_vsn} \
--norm_algorithm.vwmb ${params.norm_algorithm_vwmb} \
--norm_algorithm.modebetween_protein ${params.norm_algorithm_modebetween_protein} \
--norm_algorithm.modebetween ${params.norm_algorithm_modebetween} \
--norm_algorithm.rlr ${params.norm_algorithm_rlr} \
--norm_algorithm.msempire ${params.norm_algorithm_msempire} \
--norm_algorithm.by_group ${params.norm_algorithm_by_group} \
--norm_algorithm.all_group ${params.norm_algorithm_all_group} \
--norm_algorithm.by_contrast ${params.norm_algorithm_by_contrast} \
--rollup_algorithm ${params.rollup_algorithm} \
--dea_algorithm.deqms ${params.dea_algorithm_deqms} \
--dea_algorithm.msempire ${params.dea_algorithm_msempire} \
--dea_algorithm.msqrob ${params.dea_algorithm_msqrob} \
--dea_algorithm.ebayes ${params.dea_algorithm_ebayes} \
--dea_algorithm.msqrobsum ${params.dea_algorithm_msqrobsum} \
--dea_qval_signif ${params.dea_qval_signif} \
--dea_fc_signif ${params.dea_fc_signif} \
--dea_qvalue_threshold ${params.dea_qvalue_threshold} \
--dea_log2foldchange_threshold ${params.dea_log2foldchange_threshold} \
--output_qc_report ${params.output_qc_report} \
--output_abundance_tables ${params.output_abundance_tables} \
--output_dir ${params.output_dir} \
--output_within_timestamped_subdirectory ${params.output_within_timestamped_subdirectory}
  """
}

process addConditions {
  container 'pandas/pandas:pip-all'
  input:
    path samples, name: 'sample.input.xlsx'
    path groups_file
  output:
    path 'samples.xlsx'
  script:
  """
  modxlsx.py --input sample.input.xlsx --groups $groups_file
  """
}

process runMSDAP {
  container 'albsantosdel/test-msdap:argparse'
  publishDir params.outdir, mode: "copy", overwrite: true  
  input:
    path fastafiles
    path experiment
    path 'samples.xlsx'
  output:
    path 'msdap_results/*'
  script:
  """
  dataMakeReportTemplate_2.R --filenamepath $experiment --fastafiles $fastafiles \
  --samplefile samples.xlsx --format ${params.format} \
  --confidence_threshold ${params.confidence_threshold} \
--use_normalized_intensities ${params.use_normalized_intensities} \
--use_irt ${params.use_irt} \
--return_decoys ${params.return_decoys} \
--remove_shared_spectronaut_proteingroups ${params.remove_shared_spectronaut_proteingroups} \
--do_plot ${params.do_plot} \
--remove_lowconf ${params.remove_lowconf} \
--one_psm_per_precursor ${params.one_psm_per_precursor} \
--collapse_peptide_by ${params.collapse_peptide_by} \
--filter_min_detect ${params.filter_min_detect} \
--filter_min_quant ${params.filter_min_quant} \
--filter_fraction_detect ${params.filter_fraction_detect} \
--filter_fraction_quant ${params.filter_fraction_quant} \
--filter_by_contrast ${params.filter_by_contrast} \
--norm_algorithm.vsn ${params.norm_algorithm_vsn} \
--norm_algorithm.vwmb ${params.norm_algorithm_vwmb} \
--norm_algorithm.modebetween_protein ${params.norm_algorithm_modebetween_protein} \
--norm_algorithm.modebetween ${params.norm_algorithm_modebetween} \
--norm_algorithm.rlr ${params.norm_algorithm_rlr} \
--norm_algorithm.msempire ${params.norm_algorithm_msempire} \
--norm_algorithm.by_group ${params.norm_algorithm_by_group} \
--norm_algorithm.all_group ${params.norm_algorithm_all_group} \
--norm_algorithm.by_contrast ${params.norm_algorithm_by_contrast} \
--rollup_algorithm ${params.rollup_algorithm} \
--dea_algorithm.deqms ${params.dea_algorithm_deqms} \
--dea_algorithm.msempire ${params.dea_algorithm_msempire} \
--dea_algorithm.msqrob ${params.dea_algorithm_msqrob} \
--dea_algorithm.ebayes ${params.dea_algorithm_ebayes} \
--dea_algorithm.msqrobsum ${params.dea_algorithm_msqrobsum} \
--dea_qval_signif ${params.dea_qval_signif} \
--dea_fc_signif ${params.dea_fc_signif} \
--dea_qvalue_threshold ${params.dea_qvalue_threshold} \
--dea_log2foldchange_threshold ${params.dea_log2foldchange_threshold} \
--output_qc_report ${params.output_qc_report} \
--output_abundance_tables ${params.output_abundance_tables} \
--output_dir ${params.output_dir} \
--output_within_timestamped_subdirectory ${params.output_within_timestamped_subdirectory}
  """
}

process exportPlots{
  container 'dsp_nf-msdap:latest'
  input:
    path 'dataset.RData'
  output:
    //path 'plot.json'
    //path 'msdap_plots/*'
  script:
  """
  exportPlots.R
  """
}

workflow {
    getFasta()
    channel.of(params.file).set{experiment}
    generateSamples(experiment)
    channel.of(params.groups).set{groups_file}
    addConditions(generateSamples.out, groups_file)
    runMSDAP(getFasta.out, experiment, addConditions.out)
//    channel.from(runMSDAP.out).collectFile(name = 'dataset.RData').set{dataset}
 //   exportPlots(runMSDAP.out)
}

