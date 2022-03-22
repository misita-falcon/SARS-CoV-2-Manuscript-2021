# # #!/bin/bash
# ###########################################################optimized
# #chown -R cmmoranga: Linux_backup/
# #Download the fasta file from HPC
 cd "/Users/collinsmisita/manuscript/001_fasta_files" 

#Remove the merged file.. then generate a new one
  cat *.fasta  >> ../007_merged_fasta_file/all_runs_Merged.fasta

# # # # #Edit the file for later use
   cd ../007_merged_fasta_file/
   sed -e 's/\>MN908947.3//g' all_runs_Merged.fasta > all_runs_Merged2.fasta

# #Use pangolin to generate lineages #make sure we meet all dependencies : https://cov-lineages.org/pangolin_docs/requirements.html.. also update this as often as possible - manually
  source activate pangolin
# pangolin --update
  pangolin all_runs_Merged.fasta --outfile ../004_pangolin_reports/Pangolin_all_runs_Merged.csv -t 8

# # # # # # #Manual steps
# # # # # ###Go to https://clades.nextstrain.org and analyze the merged file download tsv, open it
# # # # #replace the space before the reference genome with _ then and 
# # # # #save it as Nextclade_Run1_10_Merged.csv and save in ../005_nextclade_reports/
 cd "/Users/collinsmisita/manuscript//005_nextclade_reports"
 curl -fsSL "https://github.com/nextstrain/nextclade/releases/latest/download/nextclade-MacOS-x86_64" -o "nextclade" && chmod +x nextclade

mkdir output
./nextclade dataset get --name 'sars-cov-2' --output-dir 'data/sars-cov-2'

./nextclade \
   --in-order \
   --input-fasta "/Users/collinsmisita/manuscript//007_merged_fasta_file/all_runs_Merged.fasta" \
   --input-dataset data/sars-cov-2 \
   --input-root-seq data/sars-cov-2/reference.fasta \
   --genes E,M,N,ORF1a,ORF1b,ORF3a,ORF6,ORF7a,ORF7b,ORF8,ORF9b,S \
   --input-gene-map data/sars-cov-2/genemap.gff \
   --input-tree data/sars-cov-2/tree.json \
   --input-qc-config data/sars-cov-2/qc.json \
   --input-pcr-primers data/sars-cov-2/primers.csv \
   --output-json output/nextclade.json \
   --output-csv output/nextclade.csv \
   --output-tsv output/nextclade.tsv \
   --output-tree output/nextclade.auspice.json \
   --output-dir output/ \
   --output-basename nextclade


###To run the nextstain pipeline locally
##prepae the nextstrain environment
conda update -n base conda
conda install -n base -c conda-forge mamba

mamba create -n nextstrain -c conda-forge -c bioconda \
  augur auspice nextstrain-cli nextalign snakemake awscli git pip
conda activate nextstrain
nextstrain check-setup --set-default
mamba update --all -c conda-forge -c bioconda

# # # #Load the Nextstrain Environment and move back tothe snakemake file
   source activate nextstrain
   cd "/Users/collinsmisita/manuscript/015_nextstrain/"
    git clone https://github.com/nextstrain/ncov.git
    cd ncov
##download the GISAID -Nextstrain submission ready data (Sequences and metadata)
###Edit the getting started file and the include and exclude file
# # # # #Run the snakemake file
   snakemake --cores 8 --profile ./my_profiles/getting_started --forceall --latency-wait  10 --rerun-incomplete

# #Use Auspice to view the file, first clear all instances using the port
 lsof -P | grep ':4000' | awk '{print $2}' | xargs kill -9
 auspice view --datasetDir auspice