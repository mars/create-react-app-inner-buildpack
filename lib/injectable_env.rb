# encoding: utf-8
require 'json'

class InjectableEnv
  DefaultVarMatcher = /^REACT_APP_/

  def self.create(var_matcher=DefaultVarMatcher)
    vars = ENV.find_all {|name,value| var_matcher===name }

    json = '{'
    is_first = true
    vars.each do |name,value|
      json += ',' unless is_first
      json += "#{escape(name)}:#{escape(value)}"
      is_first = false
    end
    json += '}'
  end

  def self.render(*args)
    $stdout.write create(*args)
    $stdout.flush
  end

  # Escape JSON name/value double-quotes so payload can be injected 
  # into Webpack bundle where all strings already use double-quotes.
  #
  def self.escape(v)
    # Force UTF-8 encoding so modern multi-lingual & emoji values work. (Thanks Ruby 1.9!)
    # Pre-escape quotes in the value, so they're double escaped in output.
    v.dup
      .force_encoding('utf-8')
      .gsub(/"/, '\"')
      .to_json
      .gsub(/(\A"|"\Z)/, '\"')
  end

end