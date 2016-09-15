## Debugging in RubyMine

If you have a bundler-cases out file at a point where you can recreate the
problem with a bundler command, change the Ruby Run Configuration accordingly:

Ruby script: /path/to/bundler/exe/bundle
Script arguments: install --deployment    # or whatever you need

Working directory: /path/to/bundler-cases/out
...
Ruby arguments: -e $stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift) -I../bundler/lib

## git bisect

To help determine when a problem was introduced into Bundler, you can
use `git bisect run` with bundler-cases as part of the larger `git bisect`
process.

You'll need some setup first: 

- a checkout of bundler available.

- setup the `dbundle` shell function. Similar to the alias as described in
  the bundler DEVELOPMENT.md doc, but the 
  function is easier to use from Ruby `system`.
  
      function dbundle(){
      BUNDLE_DISABLE_POSTIT=1 ruby -I /path/to/bundler/lib /path/to/bundler/exe/bundle "$@"
      }

- change the `execute_bundler` commands in the BundlerCase definition to 
  something like the following. Substitute the appropriate filename to source.
  
      execute_bundler { 'source ~/.bash_profile; dbundle install --path .bundle' }

- make sure the bundler-cases case works on its own, and fails. 

Now to the bisection.

From the bundler checkout, set up the `git bisect`

- `git bisect reset` # if you need to start over
- `git bisect start`
- `git bisect bad` # presumes the current commit recreates the problem
- `git bisect good v1.12.5` # use the label of the last good release (or other commit reference as appropriate)
- `git bisect run ruby -C /path/to/bundler-cases run_cases.rb name_of_case`

And it should locate the commit where the case first started failing.
