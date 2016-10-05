BundlerCase.define version: '1.13.2' do
  step do
    execute_bundler { 'gem uninstall rainpress -a -x --force' }
  end

  step do
    given_gemfile do
      <<-G
source 'https://rubygems.org'
gem 'rainpress'
      G
    end
    execute_bundler { 'bundle install' }
    expect_locked { ['rainpress', 'echoe', 'allison']}
  end

  step do
    given_lockfile { ' ##### ' } # hack to essentially remove the lockfile
    execute_bundler { 'bundle install' }
    expect_locked { ['rainpress', 'echoe', 'allison']}
  end
end
