# encoding: utf-8
require 'json'

class InjectableEnv
  DefaultVarMatcher = /^REACT_APP_/
  Placeholder='{{REACT_APP_VARS_AS_JSON}}'

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

  def self.replace(file, *args)
    env = create(*args)
    injectee = IO.read(file)
    head,_,tail = injectee.partition(Placeholder)
    injected = head + env + tail
    File.open(file, 'w') do |f|
      f.write(injected)
    end
  end

  # Escape JSON name/value double-quotes so payload can be injected 
  # into Webpack bundle where embedded in a double-quoted string.
  #
  def self.escape(v)
    v.dup
      .force_encoding('utf-8') # UTF-8 encoding for content
      .to_json
      .gsub(/\\\\/, '\\\\\\\\\\\\\\\\') # single slash in content
      .gsub(/\\([bfnrt])/, '\\\\\\\\\1') # control sequence in content
      .gsub(/([^\A])\"([^\Z])/, '\1\\\\\\"\2') # double-quote in content
      .gsub(/(\A\"|\"\Z)/, '\\\"') # double-quote around JSON token
  end

end