configure! do |m|
    m.id = :test
    m.host = /.*/
    m.priority = 100
    m.module = "test_module.rb"
end