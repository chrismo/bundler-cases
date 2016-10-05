BundlerCase.define version: '1.12.5' do
  step do
    given_gems do
      fake_gem 'foo', %w(1.0.0 1.0.1 1.1.0 2.0.0)
      fake_gem 'bar', %w(1.0.0 1.0.1 1.1.0)
      fake_gem 'qux', %w(1.0.0 1.0.1)
    end
    given_gemfile lock: ['foo 1.0.0', 'bar 1.0.0', 'qux 1.0.0'] do
      <<-G
source 'fake'
gem 'foo'
gem 'bar'
gem 'qux'
      G
    end
  end

  step do
    execute_bundler { 'bundle outdated' }
    expect_output { /bar.*foo.*qux/m }
  end

  step do
    execute_bundler { 'bundle outdated --major' }
    expect_output { /bundle:\n\s+\* foo/ }
  end

  step do
    execute_bundler { 'bundle outdated --minor' }
    expect_output { /bundle:\n\s+\* bar/ }
  end

  step do
    execute_bundler { 'bundle outdated --patch' }
    expect_output { /bundle:\n\s+\* qux/ }
  end
end
