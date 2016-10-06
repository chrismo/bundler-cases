BundlerCase.define do
  step do
    given_gems do
      fake_gem 'foo', %w(1.0.0 1.0.1 1.1.0 2.0.0)
      fake_gem 'bar', %w(1.0.0 1.0.1 1.1.0)
      fake_gem 'qux', %w(1.0.0 1.0.1)
      fake_gem 'dud', %w(1.0.0)
    end
    given_gemfile lock: ['foo 1.0.0', 'bar 1.0.0', 'qux 1.0.0'] do
      <<-G
source 'fake'
  group :foo_group do
    gem 'foo'
    gem 'bar'
  end
  gem 'qux', group: [:dev, :zep]
  gem 'dud'
      G
    end
  end

  step 'no arguments' do
    execute_bundler { 'source ~/.bash_profile; dbundle outdated' }
    expect_output { /bar.*foo.*qux/m }
    expect_exit_success { false }
  end

  step 'filter to display major only' do
    execute_bundler { 'source ~/.bash_profile; dbundle outdated --major' }
    expect_output { /bundle:\n\s+\* foo/ }
    expect_exit_success { false }
  end

  step 'filter to display minor only' do
    execute_bundler { 'source ~/.bash_profile; dbundle outdated --minor' }
    expect_output { /bundle:\n\s+\* bar/ }
    expect_exit_success { false }
  end

  step 'filter to display patch only' do
    execute_bundler { 'source ~/.bash_profile; dbundle outdated --patch' }
    expect_output { /bundle:\n\s+\* qux/ }
    expect_exit_success { false }
  end

  step 'filter to display foo_group only' do
    execute_bundler { 'source ~/.bash_profile; dbundle outdated --group foo_group' }
    expect_output { /bundle:\n.*Group foo_group.*\n\s+\* bar.*\n\s+\* foo/ }
    expect_exit_success { false }
  end

  step 'filter to display minor and patch with groups' do
    execute_bundler { 'source ~/.bash_profile; dbundle outdated --groups --patch --minor' }
    expect_output { /bundle:\n.*Group dev, zep.*\n\s+\* qux.*\n.*Group foo_group.*\n\s+\* bar/ }
    expect_exit_success { false }
  end

  step 'parseable overrides groups' do
    execute_bundler { 'source ~/.bash_profile; dbundle outdated --groups --patch --minor --parseable' }
    expect_output { /bar.*\nqux/ }
    expect_exit_success { false }
  end

  step 'update to latest' do
    execute_bundler { 'bundle update' }
  end

  step 'outdated now up to date' do
    execute_bundler { 'source ~/.bash_profile; dbundle outdated' }
    expect_output { /up.to.date/i }
    expect_exit_success { true }
  end
end
