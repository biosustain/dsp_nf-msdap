/*
 * Pipeline wrapper for MS-DAP
 */

// pipeline input paramerers:

//params.yaml = './config.yaml' //-params-file ./params.yaml
//params.mztab = './sample.mzTab'
//params.mztab = '~/cfb/mzTab/examples/1_0-Proteomics-Release/PRIDE_Exp_Complete_Ac_1643.xml-mztab.txt'

// read from yaml

//set directory relative to working dir

log.info """\
              M S - D A P  W R A P P E R
          ==================================
          github.com/biosustain/dsp_nf-msdap
          ----------------------------------
          file       : ${params.mztab}
          sample     : 
          species    : 
          contrasts  : 
          """



//potentially a process that trims the first lines away - this can be the same channel

// process readConfig{
// input:
// output:
// script:
//   """
//     ./yaml2import.py
//    """
// }

process convertTaxidToUniprot {
  output:
  stdout
  script:
  """
  python3 ~/cfb/nf/getstarted/temp/get_conversion_table.py
  """
}

process makeFastaLink {
  output:
  stdout
  script:
  """
  python3 ~/cfb/nf/getstarted/temp/species2fasta.py ${params.mztab}
  """
}

// Initiation
//channel 1
workflow{
  Channel
  convertTaxidToUniprot()
  makeFastaLink()
}

