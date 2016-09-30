# by @marcandre
#
# chrismo: to best leave existing behavior alone, there's no difference at all between
# `bundle update` and `bundle update --major` - and so the whole new code path for doing the `--patch`
# and `--minor` handling is completely skipped when `--major` is provided. Obviously, this is
# the source of the inconsistency. I think with some work on a --conservative flag, we can get some
# better stuff.
BundlerCase.define bundler_version: '1.13.2' do
  setup = step 'Setup Gemfile' do
    given_gems do
      fake_gem 'foo', '1.4.3', [['bar', '~> 2.0']]
      fake_gem 'foo', '1.4.4', [['bar', '~> 2.0']]
      fake_gem 'bar', %w(2.0.3 2.0.4)
    end

    given_gemfile lock: ['foo 1.4.3', 'bar 2.0.3'] do
      <<-G
source 'fake' do
  gem 'foo'
end
      G
    end

    expect_locked { ['foo 1.4.3', 'bar 2.0.3'] }
  end

  step do
    execute_bundler { 'bundle update' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.4'] }
  end

  repeat_step setup

  step do
    execute_bundler { 'bundle update foo' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.4'] }
  end

  repeat_step setup

  step "major" do
    execute_bundler { 'bundle update --major foo' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.4'] }
  end

  repeat_step setup

  # Specifying --minor behaves differently than --major, even though
  # the only available version available are patch releases.
  # Inconsistent, probably a bug
  step "minor" do
    execute_bundler { 'bundle update --minor foo' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.4'] }
  end

  repeat_step setup

  # Specifying --patch behaves differently than --major, even though
  # the only available version available are patch releases.
  # Inconsistent, probably a bug
  step "patch" do
    execute_bundler { 'bundle update --patch foo' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.4'] }
  end
end
