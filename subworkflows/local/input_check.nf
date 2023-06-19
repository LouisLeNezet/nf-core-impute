//
// Check input samplesheet
//

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    Channel.fromPath ( samplesheet )
        .splitCsv ( header:true, sep:',' )
        .map { create_vcf_channel(it) }
        .set { vcf }

    emit:
    vcf                                     // channel: [ val(meta), [ vcf, index ] ]
}

workflow REGION_CHECK {
    take:
    regionsheet // file: /path/to/samplesheet.csv

    main:
    Channel.fromPath ( regionsheet )
        .splitCsv ( header:true, sep:',' )
        .map { create_region_channel(it) }
        .set { region }

    emit:
    region                                    // channel: [meta, fasta, region ]
}


// Function to get list of [ meta, [ vcf, index ] ]
def create_vcf_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id  = row.sample

    // add path(s) of the vcf file(s) to the meta map
    def vcf_meta = []
    if (!file(row.vcf).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read VCF file does not exist!\n${row.vcf}"
    }
    if (!file(row.index).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read index file does not exist!\n${row.index}"
    }
    vcf_meta = [ meta, file(row.vcf), file(row.index) ]

    return vcf_meta
}

def create_region_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.region     = "$row.chr:$row.start-$row.end"
    // colapse regions in chr:start-end format
    def region_meta = []
    region_meta = [meta, "$row.chr:$row.start-$row.end"]
    return region_meta
}
