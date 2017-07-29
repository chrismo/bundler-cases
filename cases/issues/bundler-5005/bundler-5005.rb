# case from https://github.com/buehmann/bundler/tree/bundler-bug
# BundlerCase.define reuse_out_dir: true do
BundlerCase.define do
  step do
    given_bundler_version { '1.12.5' }
    execute_bundler { 'bundle install' }
  end

  step do
    given_bundler_version { '1.13.2' }
    execute_bundler { 'bundle exec ./bug' }
    expect_output { 'rake-11.3.0/lib' }
  end
end
