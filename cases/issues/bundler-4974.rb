BundlerCase.define bundler_version: '1.12.5' do
  step do
    execute_bundler { 'gem install awesome_print' }
  end

  step do
    given_gemfile lock: true do
      <<-G
source 'https://rubygems.org'

gem "awesome_print"
      G
    end

    execute_bundler { 'bundle install --deployment' }
  end

  step do
    execute_bundler { 'bundle show --paths' }
    expect_output { /\/out\/.*awesome_print/ }
  end

  step do
    given_bundler_version { '1.13.2' }
    execute_bundler { 'bundle install --deployment' }
  end

  step do
    given_bundler_version { '1.13.2' }
    execute_bundler { 'bundle show --paths' }
    expect_output { /\/out\/.*awesome_print/ }
  end
end
