configure! do |m|
    m.id = :cdn
    m.host = /cdn\..*/
    m.module = "cdn.rb"
end