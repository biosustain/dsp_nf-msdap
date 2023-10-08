/*
 * Pipeline wrapper for MS-DAP
 * run msdap headless with nextflow
 * MS-DAP originates here:
 * https://github.com/ftwkoopmans/msdap
 */

// pipeline input paramerers:

// MS format: Spectronaut, MaxQuant, Fragpipe, mzTab (experiemental)
//params.format = 

//params.yaml = './config.yaml' //-params-file ./params.yaml
//params.file = './sample.mzTab'
//params.file = '~/cfb/mzTab/examples/1_0-Proteomics-Release/PRIDE_Exp_Complete_Ac_1643.xml-mztab.txt'

//params.taxid  // list of taxID or Uniprot species

//params.fasta //list of additional fasta files to include

//params.groups // paired list of all samples with replicate name/condition

//params.contrasts /// if undefined, generate all possibilities from groups

// read from yaml

//set directory relative to working dir

// local library dir


log.info """\
              M S - D A P  W R A P P E R
          ==================================
          github.com/biosustain/dsp_nf-msdap
          ----------------------------------
          MS format  : ${params.format}
          file       : ${params.file}
          sample     : 
          library    : ${params.library}
          species    : ${params.taxid}
          fasta      : 
          groups     : ${params.groups}
          contrasts  : 
          """



//potentially a process that trims the first lines away - this can be the same channel


// If format == spectronaut / import_dataset_spectronaut
//  maxquant / import_dataset_maxquant_evidencetxt
//  proteomediscoverer  /  import_dataset_proteomediscoverer_txt (parse into R script)


/*
if(${params.format} == 'spectronaut') {

}else if(${params.format} == 'maxquant'){
  
}else if(${params.format} == 'proteomediscover'){
  
}else if(${params.format} == 'mztab'){
  
}
*/

// possibly forward parameter to python script which will take care of the input parsing 


process getFasta {
  output:
  stdout
  script:
  """
  python3 ~/cfb/dsp_nf-msdap/scripts/get_conversion_table.py --library ${params.library}
  python3 ~/cfb/dsp_nf-msdap/scripts/taxid2fasta.py --library ${params.library} --taxid ${params.taxid}
  Rscript ~/cfb/dsp_nf-msdap/scripts/dataMakeReportTemplate_1.R ${params.file} ${params.library}/proteome_${params.taxid}.fasta.gz
  python3 ~/cfb/dsp_nf-msdap/scripts/modxlsx.py --input ./samples.xslx --replicate "${params.groups}"
  Rscript ~/cfb/dsp_nf-msdap/scripts/dataMakeReportTemplate_2.R ${params.file} ${params.library}/proteome_${params.taxid}.fasta.gz
  """
}

// Initiation
//channel 1
workflow{
  Channel
  getFasta()
}

