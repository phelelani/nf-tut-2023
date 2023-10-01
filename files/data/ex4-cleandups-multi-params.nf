#!/usr/bin/env nextflow
nextflow.enable.dsl=2

data = file(params.data, type:'dir')
input_ch = Channel.fromPath("${data}/*.bim")

process getIDs {
    publishDir "clean_ids", mode: 'copy'
    
    input:
    path(input_ch)

    output:
    path("${input_ch.baseName}"), emit: id_ch
    path(input_ch), emit: orig_ch
  
    """
    cut -f 2 ${input_ch} | sort > ${input_ch.baseName}
    """
}

process getDups {
    publishDir "clean_ids", mode: 'copy'

    input:
    path(id_ch)
  
    output:
    path("${id_ch.baseName}.dups"), emit: dups_ch
  
    """
    uniq -d ${id_ch} > ${id_ch.baseName}.dups
    touch ignore
    """
}

process removeDups {
    publishDir "clean_ids", mode: 'copy'

    input:
    path(dups_ch)
    path(orig_ch)
    
    output:
    path("${orig_ch.baseName}_clean.bim"), emit: cleaned_ch
    
    """
    grep -v -f ${dups_ch} ${orig_ch} > ${orig_ch.baseName}_clean.bim
    """
}

process splitIDs {
    publishDir 'split_files', mode: 'copy'
    
    input:
    path(cleaned_ch)
    each split
  
    output:
    path("*-${split}-*"), emit: output_ch
    
    """
    split -l ${split} ${cleaned_ch} ${cleaned_ch.baseName}-$split-
    """
}

workflow {
    splits = [400,500,600]
    getIDs(input_ch)
    getDups(getIDs.out.id_ch)
    removeDups(getDups.out.dups_ch, getIDs.out.orig_ch)
    splitIDs(removeDups.out.cleaned_ch, splits).view()
}
