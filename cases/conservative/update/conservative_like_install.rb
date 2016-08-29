# Compare to install/after_gemfile_change_success.rb
#
# From the conversation here https://github.com/bundler/bundler-features/issues/122,
# this case documents how `bundle update` does not have an equivalent way to do
# a "conservative update" that you can with `bundle install` after changing a dependency
# in the Gemfile.
#
# The desire here would be to accomplish the same thing without having to change the
# Gemfile at all, but simply specify the gem name in the `bundle update` command.
BundlerCase.define do
  step 'Setup: Original Gemfile' do
    given_gems do
      fake_gem 'foo', %w(1.0.0 1.0.1 1.1.0 2.0.0), [['bar', '~> 1.0']]
      fake_gem 'qux', %w(1.0.0 1.0.1 1.1.0 2.0.0), [['bar', '~> 1.0']]
      fake_gem 'bar', %w(1.0.0 1.0.1 1.1.0 2.0.0)
    end

    lock = ['foo 1.0.1', 'bar 1.0.0', 'qux 1.1.0']

    given_gemfile lock: lock do
      <<-G
      source 'fake' do
        gem "foo"
        gem "qux"
      end
      G
    end

    expect_locked { lock }
  end

  step 'Update foo without modifying Gemfile' do
    execute_bundler { 'bundle update foo' }
    # execute_bundler { 'bundle update --conservative foo' } <= new flag idea?

    expect_locked { ['foo 2.0.0', 'bar 1.0.0', 'qux 1.1.0'] }
    # fails => Expected bar 1.0.0, found bar 1.1.0
  end
end
