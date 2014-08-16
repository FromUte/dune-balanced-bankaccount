source 'https://rubygems.org'

gemfile_url = File.join(File.dirname(__FILE__), 'spec/dummy/Gemfile')
gemfile_content = File.open(gemfile_url, 'rb') { |f| f.read }

gemspec_gems = %w(
  neighborly-balanced-bankaccount'
  neighborly-balanced'
  rspec-rails'
)
eval_gemfile gemfile_url, (gemfile_content.split("\n").reject do |line|
  line.empty? || Regexp.union(*gemspec_gems).match(line)
end.join("\n"))

gemspec
gem 'neighborly-balanced', github: 'neighborly/neighborly-balanced', branch: :master
