BundlerCase.define do
  step do
    given_gemfile { "source 'https://rubygems.org'" }
  end

  step do
    given_bundler_version { '1.10.5' }
    execute_bundler { 'bundle exec shebang_script.rb' }
    expect_output { 'bundler: command not found: shebang_script.rb' }
  end

  step do
    given_bundler_version { '1.10.5' }
    execute_bundler { 'bundle exec ruby plain_script.rb' }
    expect_output { /cannot load such file.*bin\/bundle/ }
  end

  step do
    given_bundler_version { '1.11.2' }
    execute_bundler { 'bundle exec shebang_script.rb' }
    expect_output { 'bundler: command not found: shebang_script.rb' }
  end

  step do
    given_bundler_version { '1.11.2' }
    execute_bundler { 'bundle exec ruby plain_script.rb' }
    expect_output { /cannot load such file.*bin\/bundle/ }
  end

  step do
    given_bundler_version { '1.12.5' }
    execute_bundler { 'bundle exec shebang_script.rb' }
    expect_output { "can't find executable bundle" } # this message is probably specific to RubyGems version. 2.6.x here.
  end

  step do
    given_bundler_version { '1.12.5' }
    execute_bundler { 'bundle exec ruby plain_script.rb' }
    expect_output { "can't find executable bundle" } # this message is probably specific to RubyGems version. 2.6.x here.
  end

  step do
    given_bundler_version { '1.13.2' }
    execute_bundler { 'bundle exec shebang_script.rb' }
    expect_output { 'i found bundler' }
  end

  step do
    given_bundler_version { '1.13.2' }
    execute_bundler { 'bundle exec ruby plain_script.rb' }
    expect_output { 'i found bundler' }
  end
end
