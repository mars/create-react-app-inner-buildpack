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
    injected = injectee.sub(Placeholder, env)
    File.open(file, 'w') do |f|
      f.write(injected)
    end
  end

  # Escape JSON name/value double-quotes so payload can be injected 
  # into Webpack bundle where all strings already use double-quotes.
  #
  def self.escape(v)
    # Force UTF-8 encoding so modern multi-lingual & emoji values work. (Thanks Ruby 1.9!)
    # Double-escape slashes & quotes within the encoded value.
    v.dup
      .force_encoding('utf-8')
      .to_json
      .gsub(/\\/, '\\\\\\')
      .gsub(/"/, '\"')
  end

end