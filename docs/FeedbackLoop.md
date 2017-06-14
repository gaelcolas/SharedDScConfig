# TRPM and fast feedback loop

Assuming infrastructure developers are using the [github flow](https://guides.github.com/introduction/flow/) or something similar, you want them to have a way to test their changese (in a clean resource) before pushing their commits and opening a PR.

In the quick diagram I draw below, the inner loop (in black), is the individual developper workflow, and once they `push` to their team's (or public) repository, their commits enter the wider loop (colored) where their CI/CD tools orchestrate the process (ideally automatically).

![image](https://gaelcolas.files.wordpress.com/2016/07/trpm1.png?w=768&h=540)

The 2 key elements to this workflow are:
- iterating quickly and small, to batching up changes before testing and integration with the other contributions (reducing the batch size/change scope).
- getting fast feedback (fail fast) and improve quality by using TDD

To achieve this, the response time of the development environment is critical. The quickest you can run your test and get feedback on the changes you're making, the more you will [_shift testing to the left_](https://en.wikipedia.org/wiki/Shift_left_testing) (that is, test early, not as a phase in its own later in the process).

If it takes only a **few minutes** to start testing from a clean VM, you can do it __many times an hour__.

If it takes one or more **dozens** of minutes, you can test from a clean test at best __a couple of times an hour__.

Longer and you will do it __a few times a day__ at best...

By making local change quickly and testing them locally, you can push them to the central repository more often, reducing the scope of the integration tests running on your CI environment prior to merging to your master branch.

Another way to shorten the feedback loop is by applying the [test Pyramid principle](https://martinfowler.com/bliki/TestPyramid.html) to your tests, making sure you have fast Unit tests running as early as possible in your workflow. In practice, this could be running your Unit tests, lint tests, PS Script Analyser tests as often as possible (i.e. at every file changes being saved), before you start more expensive tests. Those test must run almost instantly, or there's little benefit of moving them left in your development flow (quite the opposite, they'd delay feedback).

A word of obvious warning: don't bloat your test suites running early in your development flow, giving you information that's only required later. Optimize your feedback loop!