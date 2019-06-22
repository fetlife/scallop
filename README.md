[![Gem Version](https://badge.fury.io/rb/scallop.svg)](https://badge.fury.io/rb/scallop)
[![CircleCI](https://circleci.com/gh/fetlife/scallop.svg?style=svg)](https://circleci.com/gh/fetlife/scallop)
[![Maintainability](https://api.codeclimate.com/v1/badges/b7d9660aa51c7205fbac/maintainability)](https://codeclimate.com/github/fetlife/scallop/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b7d9660aa51c7205fbac/test_coverage)](https://codeclimate.com/github/fetlife/scallop/test_coverage)

# Scallop

![](./scallop.png)

Ergonomic shell wrapper.

Features:

* Easy access to command's output (stdout & stderr)
* Failure handling
* Parameterization
* Measuring execution time
* No dependencies

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scallop'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scallop

## Usage

To run `sudo -u chuck grep -R /home/chuck`

```ruby
result = Scallop.sudo(:chuck).cmd(:grep, '-R', '/home/chuck').run
```

You can then check whether command succeeded

```ruby
result.success?
```

See its output

```ruby
result.stdout
result.stderr
result.output # STDOUT and STDERR combined
```

You can also access information about command execution time

```ruby
result.timing.real # Elapsed real time
result.timing.stime # System CPU time
result.timing.utime # User CPU time
result.timing.total # Total time, that is utime + stime + cutime + cstime
```

### Handling failures with exceptions

If you replace `run` with `run!`, exception will be raised in case command fails

```ruby
begin
  Scallop.cmd(some_command).run!
rescue Scallop::Errors::CommandFailed => error
  # you can access result right on the error itself
  error.result.stderr
end
```

### Piping

To run `cat /some/file | grep something`

```ruby
command = Scallop.cmd(:cat, '/some/file') | Scallop.cmd(:grep, 'something')
command.run
```

### Parameterization

```ruby
stored_command = Scallop.cmd(:rm, '-rf', Scallop::Param[:path])

stored_command.set(path: '/foo').run # rm -rf /foo
stored_command.set(path: '/bar').run # rm -rf /bar
```

--------

You can also [check specs](./spec/scallop_spec.rb) for examples.
