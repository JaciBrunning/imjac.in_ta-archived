configure! do |m|
    m.id = :projects
    m.host = /proj\..*/
    m.module = "projects.rb"
end