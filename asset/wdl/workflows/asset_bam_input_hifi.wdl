version 1.0

import "../tasks/asset.wdl" as asset_t
import "../tasks/bam2paf.wdl" as bam2paf_t
import "../tasks/bam_coverage.wdl" as bam_coverage_t

workflow assetTwoPlatforms {
    input {
        String sampleName
        String sampleSuffix
        Array[File] hifiBamFiles
        Float hifiCoverageMean
        Float hifiCoverageSd
        Int minMAPQ = 21
    }

    scatter(bamFile in hifiBamFiles) {
        call bam2paf_t.bam2paf as hifiBam2Paf {
            input: 
                bamFile = bamFile,
                minMAPQ = minMAPQ
        }
    }
    
    call asset_t.ast_pbTask as hifiAssetTask{
        input:
            sampleName = "${sampleName}.${sampleSuffix}.hifi",
            pafFiles = hifiBam2Paf.pafFile,
            coverageMean = hifiCoverageMean,
            coverageSD = hifiCoverageSd,
            memSize = 32,
            threadCount = 8,
            diskSize = 256,
            preemptible = 2
    }

    output {
        File assetHiFiSupportBed = hifiAssetTask.supportBed
    }
}

