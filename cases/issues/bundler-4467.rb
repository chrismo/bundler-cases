BundlerCase.define do
  step 'setup' do
    given_gems do
      fake_gem 'foo', %w(1.0.0), [['qux', '~> 1.0']]
      fake_gem 'bar', %w(1.0.0), [['qux', '~> 1.0']]
      fake_gem 'qux', %w(1.0.0)
    end

    given_gemfile lock: [] do
      <<-G
    source 'fake' do
      gem 'foo'
      gem 'bar'
    end
      G
    end

    given_bundler_version { '1.11.2' }
    execute_bundler { 'bundle install --deployment' }
  end

  step 'first occurs in 1.11.x' do
    given_gems do
      fake_gem 'bar', '1.1.0'
    end

    given_bundler_version { '1.11.2' }
    execute_bundler { 'bundle update bar' }
    expect_output { "Your Gemfile.lock is corrupt. The following gem is missing from the DEPENDENCIES section: 'qux'" }
  end

  step 'still a problem in latest release' do
    given_bundler_version { '1.13.2' }
    execute_bundler { 'bundle update bar' }
    expect_output { "Your Gemfile.lock is corrupt. The following gem is missing from the DEPENDENCIES section: 'qux'" }
  end

  step "doesn't blow up in 1.10.5, but update doesn't happen" do
    # doesn't blow up in 1.10.5 because the corrupt check didn't even exist until 1.11.0
    # it doesn't blow up, but it still doesn't work. No update happens.
    given_bundler_version { '1.10.5' }
    execute_bundler { 'bundle update bar' }
    expect_locked { ['bar 1.0.0'] }
  end

  step '--no-deployment will remove frozen setting' do
    given_bundler_version { '1.10.5' }
    execute_bundler { 'bundle install --no-deployment --path vendor/bundle' }
  end

  step 'update will work now' do
    given_bundler_version { '1.10.5' }
    execute_bundler { 'bundle update bar' }
    expect_locked { ['bar 1.1.0'] }
  end
end
