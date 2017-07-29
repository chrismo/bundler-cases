BundlerCase.define do
  step do
    given_gemfile do
      <<-G
source "https://rubygems.org"
gem 'chef', '~> 12.1.2'
      G
    end

    given_bundler_version { '1.13.0' }

    execute_bundler { 'bundle lock' }
  end
end
