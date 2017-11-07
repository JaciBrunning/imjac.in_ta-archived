require 'jobs'

puts "[BUILDERS] Building Resources..."
Builders.builders.each do |name, builder|
    builder.submit_build!
end