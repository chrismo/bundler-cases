BundlerCase.define do
  step 'Setup: Original Gemfile' do
    given_gems do
      fake_gem 'foo', %w(1.0.0 1.0.1 1.1.0 2.0.0), [['bar', '~> 1.0']]
      fake_gem 'qux', %w(1.0.0 1.0.1 1.1.0 2.0.0), [['bar', '~> 1.0']]
      fake_gem 'bar', %w(1.0.0 1.0.1 1.1.0 2.0.0)

      fake_gem 'tak', %w(1.0.0), [['hoq', '~> 1.0']]
      fake_gem 'tak', %w(2.0.0), [['hoq', '~> 2.0']]
      fake_gem 'hoq', %w(1.0.0 2.0.0)
    end

    lock = ['foo 1.0.1', 'bar 1.0.0', 'qux 1.1.0', 'tak 1.0.0', 'hoq 1.0.0']

    given_gemfile lock: lock do
      <<-G
      source 'fake' do
        gem "foo"
        gem "qux"

        gem "tak"
      end
      G
    end

    expect_locked { lock }
  end

  step 'Change foo and tak in Gemfile then install' do
    given_gemfile do
      <<-G
      source 'fake' do
        gem "foo", "~> 2.0"
        gem "qux"

        gem "tak", "~> 2.0"
      end
      G
    end

    # bar isn't changed because it's a shared dependency, and this is how bundle install conservative updating works.
    #
    # hoq is changed because it's an isolated dependency.
    expect_locked { ['foo 2.0.0', 'bar 1.0.0', 'qux 1.1.0', 'tak 2.0.0', 'hoq 2.0.0'] }
  end
end
