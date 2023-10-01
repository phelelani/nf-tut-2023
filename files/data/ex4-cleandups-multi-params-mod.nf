#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.data = "data"
input_ch = Channel.fromPath("${params.data}/*.bim")

process getIDs {
    input:
    path(input)
    
    output:
    path("${input.baseName}.ids"), emit: id_ch
    path("${input}"), emit: orig_ch
    
    """
    cut -f 2 ${input} | sort > ${input.baseName}.ids
    """
}

process getDups {
    input:
    path(input)

    output:
    path("${input.baseName}.dups"), emit: dups_ch

    """
    uniq -d ${input} > "${input.baseName}.dups"
    touch ignore
    """
}

process removeDups {
    publishDir "output", pattern: "${badids.baseName}.bim", overwrite:true, mode:'copy'
    
    input:
    path(badids)
    path(orig)

    output:
    path("${badids.baseName}_clean.bim"), emit: cleaned_ch

    """
    grep -v -f ${badids} ${orig} > ${badids.baseName}_clean.bim
    """
}

process splitIDs  {
    publishDir 'split_files', mode: 'copy'
    
    input:
    path(bim)
    each split

    output:
    path("*-$split-*"), emit: output_ch

    """
    split -l ${split} ${bim} ${bim.baseName}-$split-
    """
}

workflow {
    splits = [400,500,600]
    getIDs(input_ch)
    getDups(getIDs.out.id_ch)
    removeDups(getDups.out.dups_ch, getIDs.out.orig_ch)
    splitIDs(removeDups.out.cleaned_ch, splits).view()
}
