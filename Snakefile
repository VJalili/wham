FILES     = "human1 human2".split()
FASTA     = "human_1kg_v37.fasta" # reference genome.  Needs to match
PATH      = "/here" #full path to the bamfile
BAMSUFFIX = ".bam" # suffix of the bam
WHAM      = "wham/bin/WHAM-GRAPHENING" #path to wham binary
WHAMOPTS  = "-k -m 30 -x 10" # wham options
MERGE     = "wham/bin/mergeIndvs" #path to merge options

SKIP      = "hs37d5,MT,GL000207.1,GL000226.1,GL000229.1,GL000231.1,GL000210.1,GL000239.1,GL000235.1,GL000201.1,GL000247.1,GL000245.1,GL000197.1,GL000203.1,GL000246.1,GL000249.1,GL000196.1,GL000248.1,GL000244.1,GL000238.1,GL000202.1,GL000234.1,GL000232.1,GL000206.1,GL000240.1,GL000236.1,GL000241.1,GL000243.1,GL000242.1,GL000230.1,GL000237.1,GL000233.1,GL000204.1,GL000198.1,GL000208.1,GL000191.1,GL000227.1,GL000228.1,GL000214.1,GL000221.1,GL000209.1,GL000218.1,GL000220.1,GL000213.1,GL000211.1,GL000199.1,GL000217.1,GL000216.1,GL000215.1,GL000205.1,GL000219.1,GL000224.1,GL000223.1,GL000195.1,GL000212.1,GL000222.1,GL000200.1,GL000193.1,GL000194.1,GL000225.1,GL000192.1,NC_007605" # seqids to skip

rule all:
     input: "merged_callset.bedpe"

rule merge:
     input: "tmp"
     output: "merged_callset.bedpe"
     params: sge_opts = ""
     shell: "{MERGE} -f tmp > merged_callset.bedpe"

rule concat:
     input: expand("{samples}.wham.bedpe", samples=FILES)
     output: "tmp"
     params: sge_opts = ""
     shell: "cat *.wham.bedpe | sort -k1,1 -k2,2n > tmp"

rule wham:
     input: "%s{samples}%s" % (PATH, BAMSUFFIX)
     output: "{samples}.wham.bedpe"
     params: sge_opts = "-pe serial 10 -l mfree=2G"
     shell:  "{WHAM} {WHAMOPTS} -a {FASTA} -e {SKIP} -f {input} > {wildcards.samples}.wham.bedpe 2> {wildcards.samples}.wham.err"
