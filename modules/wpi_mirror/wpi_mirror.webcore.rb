configure! do |m|
  m.id = :wpi_mirror
  m.host = /wpimirror\..*/
  m.module = "wpi_mirror.rb"
end