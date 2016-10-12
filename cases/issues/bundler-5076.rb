BundlerCase.define do
  step do
    given_gems do
      fake_gem 'foo', %w(1.0.0 2.0.0)
      fake_gem 'bar', %w(1.0.0 1.1.0)
    end
    given_gemfile lock: ['foo 1.0.0', 'bar 1.0.0'] do
      <<-G
source 'fake'

gem 'foo'
gem 'bar'
      G
    end
  end

  step 'filter on --patch which hides all results' do
    execute_bundler { 'bundle outdated --patch' }
    expect_output { /Bundle up to date!/ } # <= not really, it shouldn't say this
    expect_exit_success { false } # <= should still be false
  end
end
