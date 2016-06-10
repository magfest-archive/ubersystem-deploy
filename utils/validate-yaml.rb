require 'find'
require 'yaml'

files = Find.find('.').select { |p| /.*\.yaml$/ =~ p }

files.each { |f|
    puts "Attempting to validate: " + f
    YAML.load_file(f)
}

puts "All files validated correctly!"
