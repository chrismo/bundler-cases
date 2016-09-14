BundlerCase.define version: '1.12.5' do
  step do
    lock = [
      'ttfunk 1.2.0',
    ]

    given_gemfile lock: lock do
      <<-G
source "https://rubygems.org" do
  gem 'ttfunk'
end
      G
    end
  end

  step do
    given_bundler_version { '1.12.5' }
    execute_bundler { 'bundle outdated' }
    expect_output { '* ttfunk' }
  end

  step do
    given_bundler_version { '1.13.1' }
    execute_bundler { 'bundle outdated' }
    expect_output { '* ttfunk' }
  end
end
