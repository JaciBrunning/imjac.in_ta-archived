configure! do |m|
    m.id = :test2
    m.host = /fantasy\..*/
    m.priority = 1
    m.module = "test_module.rb"
end