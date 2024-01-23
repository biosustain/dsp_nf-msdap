#!/usr/bin/env nextflow

params.outdir = "results"
experiment = "$projectDir/data/${params.file}"
groups_file = "$projectDir/data/${params.groups}"

log.info """
              M S - D A P  W R A P P E R
          ==================================
          github.com/biosustain/dsp_nf-msdap
          ----------------------------------
          MS format  : ${params.format}
          experiment : $experiment
          library    : ${params.library}
          force      : ${params.force.download}
          organism   : ${params.taxid}
          groups     : $groups_file
          """

process getFasta {
  container 'pandas/pandas:pip-all'
  output:
    path "${params.library}/*.fasta.gz"
  script:
  """
  get_conversion_table.py --proteomes ${params.library} --force ${params.force.download} --taxid ${params.taxid}
  """
}

process generateSamples {
  container 'albsantosdel/test-msdap:latest'
  input:
    path experiment
  output:
    path 'samples.xlsx'
  script:
  """
  dataMakeReportTemplate_1.R $experiment ${params.format}
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
  container 'albsantosdel/test-msdap:latest'
  publishDir params.outdir, mode: "copy", overwrite: false  
  input:
    path fastafiles
    path experiment
    path samplesfile 
  output:
    path 'msdap_results/*'
  script:
  """
  dataMakeReportTemplate_2.R $experiment $fastafiles $samplesfile ${params.format}
  """
}

workflow {
    getFasta()
    //channel.of(params.file).set{experiment}
    generateSamples(experiment)
    addConditions(generateSamples.out, groups_file)
    runMSDAP(getFasta.out, experiment, addConditions.out)
}