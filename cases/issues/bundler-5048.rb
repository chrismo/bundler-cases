BundlerCase.define do
  step do
    given_rubygems_version { '2.5.1' }
    given_bundler_version { '1.13.2' }

    given_gemfile do
      <<-G
source 'https://rubygems.org'
gem 'rainpress'
      G
    end
    execute_bundler { 'bundle install' }
  end

  step do
    execute_bundler { 'bundle install --deployment' }
  end
end
