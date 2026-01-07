# Case-study optimization

## The Problem
A serious problem arose in our project.

We needed to process a data file, just over a hundred megabytes.

We already had a `ruby` program that could perform the required processing.

It worked successfully on files a couple of megabytes in size, but for the large file it was taking too long, and it wasn't clear whether it would finish at all within a reasonable time.

I decided to fix this problem by optimizing this program.

## Metric Formation
To understand whether my changes have a positive effect on program performance, I decided to use this metric: memory consumption

## Ensuring Correctness of the Optimized Program
The program came with a test. Running this test in the feedback loop prevents changes to the program logic during optimization.

## Feedback-Loop
To be able to quickly test hypotheses, I built an effective `feedback-loop` that allowed me to get feedback on the effectiveness of changes in about 3 seconds

Here's how I built the `feedback_loop`: I created a file with 10 thousand lines for quick verification of my code changes

## Understanding System Details to Find Main Growth Points
To find "growth points" for optimization, I mainly used memory_profiler and stackprof

Here are the problems that were found and solved


### Finding #1
Updated Ruby to version 3.0.0
no changes noticed

### Finding #2
Used jemalloc
no changes noticed

### Finding #3
MALLOC_ARENA_MAX=2
no changes noticed

### Finding #4
- following the advice from the readme, I decided to convert the program to streaming execution (I honestly had to peek at how other people technically implemented streaming file writing (didn't have enough time) but I understood the concept)
- valgrind showed that throughout the entire script execution after converting to streaming file reading, at peak no more than ~41.3mb of memory was used, which fits within the budget

## Results
As a result of the optimization work, we were finally able to process the data file.
We managed to improve the system metric from 500mb to ~41.3mb and fit within the given budget.
I used all the tools shown in the screencasts and now want to apply this to a work project where there are memory issues

As a bonus, the script execution time was cut in half, and essentially the script can now handle any amount of data

## Protection Against Performance Regression
To protect the achieved progress from being lost during further program changes, performance tests were updated
and a test was written to check memory before and after script execution and their difference
