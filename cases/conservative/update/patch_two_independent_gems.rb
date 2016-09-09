BundlerCase.define do
  setup = step 'Setup Gemfile' do
    given_gems do
      fake_gem 'foo', %w(1.0.0 1.0.1 1.1.0 2.0.0 2.1.0 2.2.0)
      fake_gem 'bar', %w(1.0.0 1.0.1 1.1.0 2.0.0 2.1.0 2.2.0)
    end

    given_bundler_version { '1.13.0' }

    lock = ['foo 1.0.0', 'bar 1.0.0']

    given_gemfile lock: lock do
      <<-G
source 'fake' do
  gem 'foo'
  gem 'bar'
end
      G
    end

    expect_locked { lock }
  end

  step do
    execute_bundler { 'bundle update --patch foo' }
    expect_locked { ['foo 1.0.1', 'bar 1.0.0'] }
  end

  step do
    execute_bundler { 'bundle update --patch' }
    expect_locked { ['foo 1.0.1', 'bar 1.0.1'] }
  end

  step do
    execute_bundler { 'bundle update --minor' }
    expect_locked { ['foo 1.1.0', 'bar 1.1.0'] }
  end

  step do
    execute_bundler { 'bundle update --major bar' }
    expect_locked { ['foo 1.1.0', 'bar 2.2.0'] }
  end

  step do
    execute_bundler { 'bundle update --minor' }
    expect_locked { ['foo 1.1.0', 'bar 2.2.0'] }
  end
end
