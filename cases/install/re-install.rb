BundlerCase.define version: '1.13.2' do
  step do
    given_gems { fake_system_gem 'fakogiri', '1.6.8.1' }
    given_gemfile do
      <<-G
source "fake"
gem 'fakogiri'
      G
    end

    execute_bundler { 'bundle install' }
  end

  step do
    execute_bundler { 'gem uninstall fakogiri' }
  end

  step do
    execute_bundler { 'bundle install' }
  end
end
