require 'jobs'

puts "[BUILDERS] Building Resources..."
get_all_builders.each do |name, builder|
    Jobs.submit Job.new("build_#{name.to_s}".to_sym) { builder.run_build }
end

Jobs.submit Job.new(:recurring, 90, true) { puts "RECURRING JOB RUN"; sleep 2 }