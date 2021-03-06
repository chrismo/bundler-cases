# bundler-cases
Simple integration tests for Bundler.

[![Build Status](https://travis-ci.org/chrismo/bundler-cases.svg?branch=master)](https://travis-ci.org/chrismo/bundler-cases)

bundler-cases provides a simple framework to describe various test scenarios with Bundler.

These are inspired by and similar to Bundler specs, but the Bundler codebase is a bit
large, and the goal of this repo is to be a smaller/simpler tool for non-Bundler
devs to work and communicate with.

The first case defined re-creates the [Conservative Updating](http://bundler.io/v1.12/man/bundle-install.1.html#CONSERVATIVE-UPDATING) scenario in the `bundle install` docs.

## Running Cases

To run the cases in `cases/`:

    ruby run_cases.rb

To run only the cases with `some_filter` in their filename:

    ruby run_cases.rb some_filter
    
The filter is a regexp, so this will also work:

    ./run_cases.rb install.*path
    
As well as specifying a directory:

    ./run_cases.rb cases/conservative/
