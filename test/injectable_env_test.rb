# encoding: utf-8
require './lib/injectable_env'
require 'yaml'

RSpec.describe InjectableEnv do

  describe '.create' do
    it "returns empty object" do
      expect(InjectableEnv.create).to eq('{}')
    end

    describe 'for REACT_APP_ vars' do
      before do
        ENV['REACT_APP_HELLO'] = 'Hello World'
        ENV['REACT_APP_EMOJI'] = '🍒🍊🍍'
        ENV['REACT_APP_EMBEDDED_QUOTES'] = '"e=MC(2)"'
      end
      after do
        ENV.delete 'REACT_APP_HELLO'
        ENV.delete 'REACT_APP_EMOJI'
        ENV.delete 'REACT_APP_EMBEDDED_QUOTES'
      end

      it "returns entries" do
        result = InjectableEnv.create
        parsed = JSON.parse(unescape(result))
        expect(parsed['REACT_APP_HELLO']).to eq('Hello World')
        expect(parsed['REACT_APP_EMOJI']).to eq('🍒🍊🍍')
        expect(parsed['REACT_APP_EMBEDDED_QUOTES']).to eq('"e=MC(2)"')
      end
    end
  end

  describe '.render' do
    it "writes result to stdout" do
      expect { InjectableEnv.render }.to output('{}').to_stdout
    end
  end

  describe '.replace' do
    before do
      ENV['REACT_APP_HELLO'] = 'Hello World'
    end
    after do
      ENV.delete 'REACT_APP_HELLO'
    end

    it "writes into file" do
      begin
        file = Tempfile.new('injectable_env_test')
        file.write('var injected="{{REACT_APP_VARS_AS_JSON}}"')
        file.rewind

        InjectableEnv.replace(file.path)

        expected_value='var injected="{\"REACT_APP_HELLO\":\"Hello World\"}"'
        expect(file.read).to eq(expected_value)
      ensure
        if file
          file.close
          file.unlink
        end
      end
    end
  end

  describe '.escape' do
    it 'slash-escapes the JSON token double-quotes' do
      expect(InjectableEnv.escape('value')).to eq('\"value\"')
    end
    it 'double-escapes double-quotes in the value' do
      # This looks insane, but the six-slashes '\\\\\\' test for three '\\\'
      expect(InjectableEnv.escape('"quoted"')).to eq('\\"\\\\\\"quoted\\\\\\"\\"')
    end
  end
end

# For the sake of parsing the test output, 
# undo the "injectable" JSON escape sequences.
def unescape(s)
  YAML.load(%Q(---\n"#{s}"\n))
end