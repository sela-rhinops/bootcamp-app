new git strategy: no more git commits and pushes - using branches from now on!

- it automates builds.
- it gives us a clear reference points
- it allows merges

p-lan to automate- but needs a var:

<pre>
git checkout -b 'new-feature'
git checkout new_feature
git merge master
git reflog
git push origin new_feature
</pre>

build pipeline:
