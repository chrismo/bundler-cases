BundlerCase.define reuse_out_dir: true do
  step do
    execute_bundler { 'bundle install --path .bundle' }
  end

  step do
    execute_bundler { 'bundle outdated' }
  end

  step do
    given_bundler_version { '1.12.5' }
    execute_bundler { 'bundle outdated' }
  end
end
