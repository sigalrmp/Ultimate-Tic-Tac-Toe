# Ultimate-Tic-Tac-Toe

This is the code for my multiplayer/ai ultimate tic tac toe game.

In the directory labeled C# there is the my first draft of the code
for the ai. I have no doubt that it is riddled with spelling mistakes
and generally messy code. The code can also not be run in this format.

In the other directory is my final project, written in OCaml. This
code is much nicer (although it too is for from perfect). The majority
of the source code is located in the bin directory.

## Installation

### Opam

First, you'll need to install opam, the OCaml Package Manager.  On
Fedora/CentOS/RHEL, you can try:

```
sudo dnf install opam
```

On Ubuntu, you can try:

```
add-apt-repository ppa:avsm/ppa
apt update
apt install opam
```

### Building and installing uttt

(all of the following should be in the OCaml directory)

You should be able to install all of the dependencies and build and
install the application as follows.

```
./setup.sh
```

This will take a while to finish!

At which point, the program will be installed in
`OCaml/_opam/bin/uttt`, and can be run from there:

```
_opam/bin/uttt
```

## Playing the game

I suggest opening 3 different terminals on one computer to test the
multiplayer, but it can be installed on and played from multiple
computers.
