# Guess how much?

I love to brag about how little I spent.

## Getting started

Install libraries:

```
bundle install
```

Then (prompt will auto-run):

```
ruby ssense/prompt.rb
```

## Debuggin

If you want to debug, you can prevent it from auto-running:

```
RUN=false irb
```

You can then interact with the prompt directly:

```
3.2.2 :001 > require_relative 'ssense/prompt'
 => true
3.2.2 :002 > prompt = Prompt.new(run: false)
 =>
#<Prompt:0x00000001107105a0
...
3.2.2 :003 > puts prompt.designers.first
 => {:value=>"/en-us/men/sale", :name=>"All designers"}
```

## Development

- Ruby/Bundler
- Environment variables
