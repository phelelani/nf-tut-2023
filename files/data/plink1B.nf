#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 Have a look at the data directory
 Run this program by saying
 nextflow plink1B.nf --pops A,martian
*/

data = "data/pops"
populations = params.pops.split(",")

Channel.from(populations)
    .map { pop -> [file("$dir/${pop}.bed"),
                   file("$dir/${pop}.bim"),
                   file("$dir/${pop}.fam")]}
    .set { plink_data }

process getFreq {
    publishDir "output"
    echo true
    
    input:
    path(plinks)

    output:
    path(output), emit: result

    script:
    bed = plinks[0]
    bim = plinks[1]
    fam = plinks[2]
    base = "${bed.baseName}"
    output = "${base}.frq"

    """
     #If you have plink, then uncomment the line below
     #plink --bed $bed --bim $bim --fam $fam --freq --out ${bed.baseName}
     #But since you probably don't have plink
     echo plink --bed $bed --bim $bim --fam $fam --freq --out ${bed.baseName}
     echo "Interesting numbers" >> $output
     """
}

workflow {
    getFreq(plink_data).view()
}

