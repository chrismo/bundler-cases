BundlerCase.define bundler_version: '1.15.0' do
  setup = step 'Setup Gemfile' do
    given_gems do
      fake_gem 'foo', '1.4.3', [['bar', '~> 2.0']]
      fake_gem 'foo', '1.4.4', [['bar', '~> 2.0']]
      fake_gem 'foo', '1.4.5', [['bar', '~> 2.1']]
      fake_gem 'foo', '1.5.0', [['bar', '~> 2.1']]
      fake_gem 'foo', '1.5.1', [['bar', '~> 3.0']]
      fake_gem 'bar', %w(2.0.3 2.0.4 2.1.0 2.1.1 3.0.0)
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

  step 'README case 1' do
    execute_bundler { 'bundle patch' }
    expect_locked { ['foo 1.4.5', 'bar 2.1.1'] }
  end

  repeat_step setup

  # bar moves in this case, even though it starts locked, because it's free to move when foo's REQUIREMENT for bar
  # changes,AND nothing else keeps it put, because it's not a declared dependency. It's technically locked, but
  # it's not a vertex(?) in the resolver either, so it can move if it has to when foo moves.
  step 'README case 2' do
    execute_bundler { 'bundle patch foo' }
    # expect_locked { ['foo 1.4.4', 'bar 2.0.3'] } <= what i thought based on non-dependent case (rack, addressable)
    expect_locked { ['foo 1.4.5', 'bar 2.1.1'] }
  end

  repeat_step setup

  step 'README case 3' do
    execute_bundler { 'bundle patch --minor' }
    expect_locked { ['foo 1.5.1', 'bar 3.0.0'] }
  end

  repeat_step setup

  step 'README case 4' do
    execute_bundler { 'bundle patch --minor --strict' }
    expect_locked { ['foo 1.5.0', 'bar 2.1.1'] }
  end

  repeat_step setup

  step 'README case 5' do
    execute_bundler { 'bundle patch --strict' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.4'] }
  end

  repeat_step setup

  step 'README case 6' do
    execute_bundler { 'bundle patch --minimal' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.4'] }
  end

  repeat_step setup

  # why doesn't `patch --strict foo` push this to 2.0.4? it pushes foo to 1.4.4.
  # because bar is locked, and the foo requirement DOESN'T CHANGE so bar stays locked
  # because sorting puts the current version as the version to pick first for locked gems.
  # Compare to case 5.
  step 'README case 7' do
    execute_bundler { 'bundle patch --strict foo' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.3'] }
  end

  repeat_step setup

  step 'README case 8' do
    execute_bundler { 'bundle patch --minimal --minor' }
    expect_locked { ['foo 1.5.0', 'bar 2.1.0'] }
  end
end
