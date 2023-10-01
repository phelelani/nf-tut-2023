#!/usr/bin/env nextflow
nextflow.enable.dsl=2

input_ch = Channel.fromPath("11.bim")

process getIDs {
    input:
    path(input_ch)
    
    output:
    stdout emit: id_ch
    path("11.bim"), emit: orig_ch

    """
    cut -f 2 ${input_ch} | sort
    """
}

process getDups {
    input:
    stdin id_ch

    output:
    stdout emit: dups_ch

    """
    uniq -d -
    touch ignore
    """
}

process removeDups {
    input:
    path(orig_ch)
    stdin dups_ch

    output:
    path("clean.bim"), emit: output

    """
    grep -v -f - ${orig_ch} > clean.bim
    """
}

workflow {
    getIDs(input_ch)
    getDups(getIDs.out.id_ch)
    removeDups(getIDs.out.orig_ch, getDups.out.dups_ch).subscribe { print "Done!" }
}
