#!/usr/bin/env nextflow
nextflow.enable.dsl=2

inp_channel = Channel.fromFilePairs("data/*dat", size: -1) { f -> ...... }

process pasteData {
    publishDir ....

    input:
    tuple val(key), path(data)

    output:
    path("${key}.res"), emit: concat_ch 

    script:
    " ... "
}

process concatData {
    publishDir "output", overwrite:true, mode:'move'

    input:
    path(concat_ch).toList()

    output:
    ....

    script:
    " .... "
}

workflow {
    pasteData(...)
    concatData(...).view()
}


