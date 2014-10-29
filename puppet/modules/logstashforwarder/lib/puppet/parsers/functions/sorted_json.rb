#
# sorted_json.rb
# Puppet module for outputting json in a sorted consistent way. I use it for creating config files with puppet
 
require 'json'
 
def sorted_json(json)
    if (json.kind_of? String)
      return json.to_json
    elsif (json.kind_of? Array)
      arrayRet = []
      json.each do |a|
        arrayRet.push(sorted_json(a))
      end
      return "[" << arrayRet.join(',') << "]";
    elsif (json.kind_of? Hash)
      ret = []
      json.keys.sort.each do |k|
        ret.push(k.to_json << ":" << sorted_json(json[k]))
      end
      return "{" << ret.join(",") << "}";
    end
    raise Exception("Unable to handle object of type " + json.class)
end
 
module Puppet::Parser::Functions
  newfunction(:sorted_json, :type => :rvalue, :doc => <<-EOS
This function takes data, outputs making sure the hash keys are sorted
 
*Examples:*
 
    sorted_json({'key'=>'value'})
 
Would return: {'key':'value'}
    EOS
  ) do |arguments|
 
    raise(Puppet::ParseError, "sorted_json(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1
 
    json = arguments[0]
    return sorted_json(json)
 
  end
end
 
# vim: set ts=2 sw=2 et :
