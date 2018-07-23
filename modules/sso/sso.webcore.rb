configure! do |m|
    m.id = :sso
    m.host = /auth\..*/
    m.module = "sso.rb"
end