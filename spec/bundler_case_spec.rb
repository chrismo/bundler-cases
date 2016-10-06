require_relative 'spec_helper'

# Not a lot of specs in here because so many of the cases themselves will exercise the core framework
# and in essence test it. This is lazy, but also hasn't been a problem thus far. Sure, in the future
# I may regret this the day I think Bundler has a bug but it turns out the framework here has one.

describe BundlerCase do
  after do
    dir = BundlerCase.new.out_dir
    FileUtils.remove_entry_secure(dir) if File.exist?(dir)
  end

  it 'given gems' do
    c = BundlerCase.define do
      given_gems do
        fake_gem 'foo', %w(1.0.0 1.0.1), [['bar', '~> 1.0']]
      end
    end
    c.test
    gems_dir = File.join(c.repo_dir, 'gems')
    expect(File.exist?(File.join(gems_dir, 'foo-1.0.0.gem'))).to be true
    expect(File.exist?(File.join(gems_dir, 'foo-1.0.1.gem'))).to be true
  end

  it 'integration success' do
    c = BundlerCase.define do
      step do
        given_gems do
          fake_gem 'foo', '1.0.0', [['bar', '~> 1.0']]
          fake_gem 'bar', '1.0.1'
        end

        given_gemfile do
          <<-G
          source 'fake' do
            gem 'foo'
          end
          G
        end

        execute_bundler { 'bundle install --path zz' }
        expect_locked { ['foo 1.0.0', 'bar 1.0.1'] }
        expect_exit_success { true }
      end

      step do
        given_gems do
          fake_gem 'foo', '1.1.0'
        end

        execute_bundler { 'bundle update' }
        expect_locked { ['foo 1.1.0'] }
        expect_not_locked { %w(bar) }
      end
    end
    result = c.test
    expect(result).to be true
    expect(c.failures).to be_empty

    dest = File.join(c.out_dir, 'zz', 'ruby', '*', 'gems', 'foo-1.0.0')
    expect(File.exist?(Dir[dest].first)).to be true
  end

  it 'integration failure' do
    c = BundlerCase.define do
      given_gems do
        fake_gem 'foo', '1.0.0', [['bar', '~> 1.0']]
        fake_gem 'bar', '1.0.1'
      end

      given_gemfile do
        <<-G
          source 'fake' do
            gem 'foo'
          end
        G
      end

      execute_bundler { 'bundle install --path zz' }
      expect_locked { ['foo 1.0.0', 'bar 1.1.0'] }
    end
    expect(c.test).to_not be true
    expect(c.failures).to_not be_empty
    expect(c.failures.first).to eql 'Expected bar 1.1.0, found bar 1.0.1'

    dest = File.join(c.out_dir, 'zz', 'ruby', '*', 'gems', 'foo-1.0.0')
    expect(File.exist?(Dir[dest].first)).to be true
  end

  it 'lock option to given_gemfile' do
    c = BundlerCase.define do
      given_gems do
        fake_gem 'foo', %w(1.0.0 1.0.2 1.1.0), [['bar', '~> 1.0']]
        fake_gem 'bar', %w(1.0.1 1.0.3 1.3.4)
      end

      given_gemfile lock: ['foo 1.0.2', 'bar 1.0.3'] do
        <<-G
        source 'fake' do
          gem 'foo', '~> 1.0'
        end
        G
      end

      expect_locked { ['foo 1.0.2', 'bar 1.0.3'] }
    end
    c.test
    expect(c.failures).to eql []
  end
end

describe ExpectedSpecs do
  def spec(name, version=nil)
    Gem::Specification.new(name, version)
  end

  it 'reports no errors by default' do
    expect(ExpectedSpecs.new.failures([], [])).to eql []
  end

  it 'reports errors for diff version' do
    failures = ExpectedSpecs.new.failures([spec('foo', '1.0.0')], [spec('foo', '1.0.1')])
    expect(failures).to eql ['Expected foo 1.0.0, found foo 1.0.1']
  end

  it 'reports errors for missing gem' do
    failures = ExpectedSpecs.new.failures([spec('foo', '1.0.0')], [])
    expect(failures).to eql ['Expected foo 1.0.0, gem not found']
  end

  it 'does not report error for no version specified' do
    failures = ExpectedSpecs.new.failures([spec('foo')], [spec('foo', '1.0.1')])
    expect(failures).to eql []
  end
end
