# https://github.com/bundler/bundler/issues/4945
BundlerCase.define do
  given_gemfile do
    <<-G
source 'https://rubygems.org' do
  gem 'rails', '~> 5.0'
  gem 'wistia'
end
    G
  end

  given_bundler_version { '1.12.5' }

  execute_bundler { 'bundle install --path .bundle && bundle env' }

  expect_locked { ['wistia 0.1.0'] }
end
