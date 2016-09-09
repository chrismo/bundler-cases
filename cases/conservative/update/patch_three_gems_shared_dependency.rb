BundlerCase.define do
  setup = step 'Setup Gemfile' do
    given_gems do
      fake_gem 'foo', '1.4.3', [['bar', '~> 2.0']]
      fake_gem 'foo', '1.4.4', [['bar', '~> 2.0']]
      fake_gem 'foo', '1.4.5', [['bar', '~> 2.1']]
      fake_gem 'foo', '1.5.0', [['bar', '~> 2.1']]
      fake_gem 'foo', '1.5.1', [['bar', '~> 3.0']]

      fake_gem 'qux', '1.4.3', [['bar', '~> 2.0']]
      fake_gem 'qux', '1.4.4', [['bar', '~> 2.0']]
      fake_gem 'qux', '1.4.5', [['bar', '~> 2.1']]
      fake_gem 'qux', '1.5.0', [['bar', '~> 2.1']]
      fake_gem 'qux', '1.5.1', [['bar', '~> 3.0']]

      fake_gem 'bar', %w(2.0.3 2.0.4 2.1.0 2.1.1 3.0.0)
    end

    given_bundler_version { '1.13.0' }

    given_gemfile lock: ['foo 1.4.3', 'bar 2.0.3', 'qux 1.4.3'] do
      <<-G
source 'fake' do
  gem 'foo'
  gem "qux"
end
      G
    end

    expect_locked { ['foo 1.4.3', 'bar 2.0.3', 'qux 1.4.3'] }
  end

  step do
    execute_bundler { 'bundle update --patch foo' }
    expect_locked { ['foo 1.4.5', 'bar 2.1.1', 'qux 1.4.3'] }
  end

  step do
    given_gems { fake_gem 'bar', '2.1.2' }

    execute_bundler { 'bundle update --patch' }
    expect_locked { ['foo 1.4.5', 'bar 2.1.2', 'qux 1.4.5'] }
  end

  step do
    given_gems { fake_gem 'bar', '2.2.1' }

    execute_bundler { 'bundle update --minor bar' }
    expect_locked { ['foo 1.4.5', 'bar 2.2.1', 'qux 1.4.5'] }
  end

  step do
    execute_bundler { 'bundle update --minor --strict' }
    expect_locked { ['foo 1.5.0', 'bar 2.2.1', 'qux 1.5.0'] }
  end

  step do
    execute_bundler { 'bundle update --minor' }
    expect_locked { ['foo 1.5.1', 'bar 3.0.0', 'qux 1.5.1'] }
  end
end
