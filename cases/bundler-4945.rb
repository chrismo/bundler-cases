# https://github.com/bundler/bundler/issues/4945
BundlerCase.define do
  given_gemfile do
    <<-G
source 'https://rubygems.org'

gem 'rails', '~> 5.0.0'
gem 'activeresource', '>= 2.3.8'
    G
  end

  given_bundler_version { '1.12.5' }

  execute_bundler { 'DEBUG=1 DEBUG_RESOLVER=1 bundle lock 2>&1 | tee output.txt' }
end
