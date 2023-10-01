#!/usr/bin/env nextflow
nextflow.enable.dsl=2

script = Channel.fromPath("*nf")

// NB: When this runs, it runs in a directory such as
// work/6b/6adfc8bc0760d67224e3cec381a839/ relative to the where you run it.

process showFiles {
    publishDir "output", overwrite: true
    echo true
    
    input:
    path(script)

    output:
    path(output), emit: result

    script:
    output = "${script.baseName}.out"

    """
    echo "I am running on `hostname`"
    echo "Current directory <`pwd`"
    echo "Check who owns  it"
    ls -ld .
    echo "This is a directory of the host that Docker mounts"
    ls ../../../..
    echo "This is the home directory of the Docker machine"
    ls \$HOME
    touch ${output}
    """
}
      
workflow {
    showFiles(script).view()
}
