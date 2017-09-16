require 'jobs'

puts "[BUILDERS] Building Resources..."
get_all_builders.each do |name, builder|
    Jobs.submit("build_#{name.to_s}".to_sym) { builder.run_build }
end