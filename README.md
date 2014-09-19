resque_instrumentation
======================

Plugin to that adds instrumentation notifications to Resque's existing [hooks](https://github.com/resque/resque/blob/1-x-stable/docs/HOOKS.md).

Depends on Resque `~> 1.24`

## Purpose

Gain visibility into Resque's operation by instrumenting major Resque lifecycle events.

## Installation

Install the gem directly:

```session
$ gem install resque_instrumentation
```

Or add it to your `Gemfile`

```ruby
gem 'resque_instrumentation', git: "git@github.com:rwdaigle/resque_instrumentation.git"
```

Worker level instrumentation is automatically enabled. To add instrumentation to your jobs (which is where the bulk of the hooks are), simply extend the `Instrumentation::Job` module in your job class:

```ruby
class MyJob
  extend Resque::Plugins::Instrumentation::Job  
  # ...
end
```

## Instrumentors

By default, resque_instrumentation discards emitted events. To do anything interesting you will need to specify an instrumentor which receives events directly from Resque and operates on them. An instrumentor is anything that adheres to the [ActiveSupport::Notifications API](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) by responding to `instrument(name, params = {}, &block)`.

### ActiveSupport::Notifications

```ruby
Resque::Plugins::Instrumentation.instrumentor = ActiveSupport::Notifications
ActiveSupport::Notifications.subscribe(/^resque\.*/) do |name, start, finish, id, payload|
  # do what you want
end
```

### Custom

A custom instrumentor would look something like this:

```ruby
class LoggingInstrumentor

  def initialize(stream)
    @stream = stream
  end

  def instrument(name, params = {}, &block_given)
    stream.puts("event=#{name}.start #{params.inspect}")
    if(block_given?)
      result = yield
      stream.puts("event=#{name}.end")
      return result
    end
  end
end

Resque::Plugins::Instrumentation.instrumentor = LoggingInstrumentor.new(STDOUT)
```

## Events

`resque_instrumentation` simply instruments each of Resque's existing hooks. The list of events instrumented is:

Target | Hook | Event name | Event params
-------|------|-------|---------------
Worker | before_first_fork | resque.before_first_fork | -
Worker | before_fork | resque.before_fork | -
Worker | after_fork | resque.after_fork | -
Job | before_enqueue | resque.before_enqueue | queue, job, args
Job | after_enqueue | resque.after_enqueue | queue, job, args
Job | before_dequeue | resque.before_dequeue | queue, job, args
Job | after_dequeue | resque.after_dequeue | queue, job, args
Job | before_perform | resque.before_perform | queue, job, args
Job | perform | resque.perform | queue, job, args
Job | after_perform | resque.after_perform | queue, job, args
Job | on_failure | resque.on_failure | exception, queue, job, args


Please see the Resque hook docs for [additional details](https://github.com/resque/resque/blob/1-x-stable/docs/HOOKS.md).

## FAQs

### Why not hooks?

Resque already has hooks in place that let you plug in to the before and after points of most major operations, couldn't I just add my desired instrumentation directly like this?

```ruby
class MyJob
  def around_perform_with_instrumentation(*args)
    ActiveSupport::Notifications.instrument("resque.perform") { yield }
  end
end
```

Absolutely you can! However, this plugin provides the following benefits:

* Distribution: Once you have any architectural sophistication in your system, you will need a way to share common instrumentation logic, whether it be in a common `Job` superclass or something else. Being a Resque plugin, it solves the distribution issue, is easily shared amongst the various apps in your system, and encourages an idiomatic approach to instrumentation.
* Flexibility: The plugin is architected in a way that is instrumentation framework agnostic. Rest easy knowing you can switch out your current ActiveSupport::Notifications instrumentor with a custom implementation by changing a single line.
