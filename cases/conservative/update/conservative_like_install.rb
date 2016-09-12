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

    expect_locked { ['foo 2.0.0', 'bar 1.1.0', 'qux 1.1.0'] }
  end

  # Desired behavior with proposed flag by some users:
  #
  # step 'Update foo without modifying Gemfile' do
  #   execute_bundler { 'bundle update --conservative foo' }
  #
  #   expect_locked { ['foo 2.0.0', 'bar 1.0.0', 'qux 1.1.0'] }
  #
  #   Conservative in this case means: "Don't move any dependencies relied on by others. Same as conservative `bundle install` does."
  #   This flag is different from --major/--minor/--patch because in it the user doesn't care about the destination of the version
  #   being updated to ... they just want to restrict how impactful it is to dependencies.
  #
  #   But of course, by default, the flags will be able to be combined, so we'd need to think through expected results of
  #   combinations of these flags. Seems reasonable to want/use --conservative AND --major/--minor/--patch.
  #
  #   Moar thoughts - `--conservative` is too generic a name. What we want, I think, is `--lock-shared-dependencies`.
  #   So far at least, that, while a long option to type, appears to best capture what is happening.
  # end
end
