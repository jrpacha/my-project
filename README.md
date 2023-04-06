# Template for C/C++/Fortran projects
You can create a github repository for your project using this template, then
clone it to your local machine, add all your stuff and push it to 
[github.com](https://www.github.com).

- First in, [github.com](htpps://www.github.com), create a _repo_ for your project
using this template. From now on, I assume this is already done and you have 
named your project as `my-project`.

- Then, clone the repo to some local folder in your machine. To fix ideas,
let's clone it in the directory <tt>Desktop</tt> of your _local_ user account,
```bash
~ $ cd Desktop
~ Desktop$ git clone git@github.com:jrpacha/my-project
~ Desktop/ cd my-project
~ Desktop/my-project$ 
```
- Place your source (<tt>.c</tt>/<tt>.cc</tt>/<tt>.f</tt>)
files in the folder <tt>src</tt>. For example:
```bash
~ Desktop/my-project$ ls src
main.cc    message.cc
```
- Place your header files (<tt>.h</tt>/<tt>.hh</tt>) in folder
<tt>include</tt>. For example:
```bash
~ Desktop/my-project$ ls include
message.hh
```
- Use `make` to build the program. This creates a new directory,
<tt>bin</tt> and builds the project's executable file in it. The executable
file is created with the same name as the project's folder,
```bash
~ Desktop/my-project$ make
g++-12 -g -O0 -W -fPIC -I/opt/homebrew/include -I/opt/homebrew/opt/llvim/include -cpp -MMD -MP -MF .d/main.Td  -Iinclude -c src/main.cc -o.o/main.o
mv -f .d/main.Td .d/main.d
g++-12 -g -O0 -W -fPIC -I/opt/homebrew/include -I/opt/homebrew/opt/llvim/include -cpp -MMD -MP -MF .d/message.Td  -Iinclude -c src/message.cc -o.o/message.o
mv -f .d/message.Td .d/message.d
g++-12 -o bin/my-project .o/main.o .o/message.o   -L/opt/homebrew/lib   -L/opt/homebrew/lib

my-project built in directory bin
```
- To run the program,
```bash
~ Desktop/my-project$ ./bin/my-project
my_project: template for my projects in FORTRAN77/C/C++
See README.md for more information.
```
- Alternatively `make run` runs the program as well,
```bash
~ Desktop/my-project$ make run
my_project: template for my projects in FORTRAN77/C/C++
See README.md for more information.
```
- `make clean` clears object and dependence files, actually what it does is
to delete the folders <tt>.o</tt> and <tt>.d</tt>, and all its content,
i.e.,
```bash
~ Desktop/my-project$ make clean
rm -f .o/*.o .d/*.d
rmdir .o .d
```
- `make mrproper` removes also the <tt>bin</tt> directory that held the
executable file,
```bash
~ Desktop/my-project$ make mrproper
rm -f .o/*.o .d/*.d
rmdir .o .d
rm -rf bin
```
- Optional: replace this <tt>README.md</tt> with a new one with a
description of your project.
- Stage and commit your changes:
```bash
~ Desktop/my-project$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   Makefile
        modified:   README.md
        modified:   src/message.cc

no changes added to commit (use "git add" and/or "git commit -a")
``` 
-

### References
- [GNU Make. A program for Directing
Recompilation](https://make.mad-scientist.net/papers/advanced-auto-dependency-generation). 
- [Generating Prerequisites Automatically](https://www.gnu.org/software/make/manual/html_node/Automatic-Prerequisites.html),
section 4.14 of the [GNU Make
Manual](https://www.gnu.org/software/make/manual/) at
[gnu.org](www.gnu.org).
- [Practical Makefiles, by
example](http://nuclear.mutantstargoat.com/articles/make/) by John
Tsiombikas <a
href="mailto:nuclear@member.fsf.org">nuclear@member.fsf.org</a>. I wrote
the `Makefile` in this template ifollowing sections 5 and 6 of this document.
