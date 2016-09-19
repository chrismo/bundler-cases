BundlerCase.define bundler_version: '1.12.5' do
  step do
    given_gemfile { "source 'https://rubygems.org'" }
  end

  step do
    execute_bundler { 'bundle exec ruby script.rb' }
    expect_output { "can't find executable bundle" }
  end

  step do
    given_bundler_version { '1.13.1' }
    execute_bundler { 'bundle exec ruby script.rb' }
    expect_output { 'i found bundler' }
  end
end
