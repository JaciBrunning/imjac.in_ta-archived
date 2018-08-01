configure! do |m|
    m.id = :blog
    m.host = /.*/
    m.priority = 100
    m.module = "blog.rb"
end