#ENV["dir"] ? @dir=ENV["dir"] : nil
ENV["project"] ? @project=ENV["project"] : nil
ENV["queue"] ? @queue=ENV["queue"] : @queue="tsl-medium"

directory "results/fastqc"
directory "results/trimmomatic"
directory "results/alignment"

task :fastqc=>["results/fastqc"] do
	sh "./run_fastqc #{@project} results/fastqc #{@queue}"
	puts "FASTQC completed"
end

task :trimmomatic=>["results/trimmomatic"] do
	sh "./run_trimmomatic #{@project} results/trimmomatic #{@queue}"
	puts "Trimmomatic completed"
end

task :alignment do
	sh "./run_alignment #{@project}"
	puts "Alignment completed"
end


task :default do
	puts "Pipeline Completed"
end
