### Note
*Ruby 2.4+ is required for the script to work*

# Task #2
In this task, you need to optimize the program from the first task, but now with a focus on memory optimization.

## Budget
The program should not consume more than **70MB** of memory when processing the `data_large` file throughout its entire execution.

## Hints
From the budget, it's clear that we can neither read the entire file into memory nor accumulate user data in memory.

This means the program needs to be rethought and written in a "streaming" style - where we read the source file line by line and immediately write the results file on the fly.

This time, to pass the test, it's sufficient for the result to match the reference as a `json` object, not a string. That is, the order of fields in the object doesn't matter.

We can assume that all user sessions always come in one continuous block. There's no case where part of a user's sessions come first, then another user's sessions, and then the first user's sessions again.


## Work Plan
This time a radical rework is required, so you need to do two stages:

- convert the program to a streaming approach so that it passes the tests
- profile the resulting program with the tools we've covered and optimize memory even further, do two or three iterations following the optimization framework and write a `case-study`
- when finished, measure the program's execution time; did it turn out faster than when optimizing for CPU in the first task?


## How to Measure Memory Usage
In the feedback loop, you can get the amount of memory *at the end* of program execution:

```ruby
puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)"
```

After successful optimization, you additionally need to profile the program using `valgrind massif visualizer` and verify that memory fits within the budget not only at the end of program execution, but throughout the entire runtime.

## Task Submission
To submit the task, you need to fork this project, make a `PR` to it, and send the link for review.

In the `PR`:
- optimizations should be made to `task-2.rb`;
- there should be a `case-study.md` file describing the optimization performed;
- the description should include a screenshot from `valgrind massif visualizer` showing that the program fits within the budget throughout execution;
- add a checklist to the `PR` description and mark what you've completed; for maximum benefit, everything should be marked.

## Checklist
- [ ] Build and analyze a report with the `memory_profiler` gem
- [ ] Build and analyze a `ruby-prof` report in `Flat` mode;
- [ ] Build and analyze a `ruby-prof` report in `Graph` mode;
- [ ] Build and analyze a `ruby-prof` report in `CallStack` mode;
- [ ] Build and analyze a `ruby-prof` report in `CallTree` mode with visualization in `QCachegrind`;
- [ ] Build and analyze a text report from `stackprof`;
- [ ] Build and analyze a `flamegraph` report using `stackprof` and visualize it in `speedscope.app`;
- [ ] Build a memory consumption graph in `valgrind massif visualizer` and include a screenshot in your `PR` description;
- [ ] Write a test that verifies the program fits within the memory budget

You don't need to include the output of all these reports in the `PR`, just use each one at least once in your `Case-study`.

## Case-study Step Format
Each optimization step in the `case-study` should contain four components:
- which report showed the main growth point
- how you decided to optimize it
- how the metric changed
- how the profiler report changed

## Notes
- Don't disable GC when measuring the metric
- Disable the profiler when measuring the metric
- Use all the described tools and reports at least once - learn to work with them!
- Invest in development convenience and feedback loop speed!
