# Variables, Line by Line


## How to read this script

Same format as *Insertion Sort, Line by Line*. **Type:** is what goes into the editor on screen, exactly. **Say:** is what you say while or after typing it. Screen is the editor on one side and a terminal on the other, like the Workbench. Run the program every time the script says *run*, so the viewer sees output change, not just code.

Target length: about four minutes. The program is nine lines; the experiment at the end is the part people will remember.

## Cold open: a declaration is a reservation

**Screen:** empty editor.

**Say:** Hey everyone, Obi here. Today we're going back to the very beginning: variables. I'm working through C++ from scratch right now, and this is the first thing that made me stop and think. Every program you'll ever write starts by reserving a little bit of memory and giving it a name. That's all a variable is. Not a number. A reservation. So: one tiny program, three variables, and one experiment at the end that explains a bug you'll meet for the rest of your life. Let's go.

**Type:**

```cpp
#include <iostream>
#include <string>
using namespace std;

int main() {

  return 0;
}
```

**Say:** The skeleton first. `iostream` is the library that lets us print. `string` is the library that gives us a text type; we'll need it in a second. `using namespace std` means I can write `cout` instead of `std::cout`. `main` is where the program starts, and `return 0` is how it says "done, no problems." Everything we write goes between those two lines.

## The program, line by line

### Line 1: a string

**Type** (inside main, above `return 0;`):

```cpp
  string name = "John";
```

**Say:** Read every declaration the same way, left to right: *type, name, value*. The type is `string`: text. The name is `name`. The value is `"John"`, in double quotes because it's text. The computer reserves enough memory to hold the word John, writes the name `name` on the door, and puts John inside. From now on, anywhere I write `name`, I mean whatever is in that box.

### Line 2: an int

**Type:**

```cpp
  int age = 35;
```

**Say:** Same shape. Type `int`, which means a whole number: no decimal point. Name `age`. Value 35. An `int` is four bytes on this machine, so this reservation is four bytes with `age` on the door and 35 inside.

### Line 3: a double

**Type:**

```cpp
  double height = 6.1;
```

**Say:** Type `double`: a number that can have a decimal point. Eight bytes. Name `height`, value 6.1. Notice I had to pick a different type to hold 6.1. We'll see what happens if I don't, at the end.

**Say** (pause on the three lines): Three boxes. Three types, three sizes, three names. That's what a variable is: a typed, named piece of memory with something in it.

### Line 4: print them

**Type:**

```cpp
  cout << name << " is " << age << " years old and " << height << " feet tall.";
```

**Say:** `cout` is the screen. Each `<<` pushes one more thing onto it, left to right: the contents of `name`, then the text `" is "`, then the contents of `age`, and so on. Things in quotes are printed as they are. Things without quotes are looked up: `age` becomes 35. `cout` knows how to print all three types; you don't have to tell it.

**Run.** Terminal shows: `John is 35 years old and 6.1 feet tall.`

**Say:** Nine lines, three reservations, one print. That's the whole program. Now let's break it on purpose.

## One experiment

### The wrong type

**Say:** What if I'd been lazy and used `int` for the height?

**Type** (change line 3 only):

```cpp
  int height = 6.1;
```

**Run.** Terminal shows: `John is 35 years old and 6 feet tall.`

**Say:** No error. No warning by default. It just threw the point-one away, because an `int` box has nowhere to put it. The type isn't a label; it's the shape of the box, and the box decides what survives. This is why you pick the type first and the value second. Change it back, and that's the finished program.

**Type:**

```cpp
  double height = 6.1;
```

**Final program on screen:**

```cpp
#include <iostream>
#include <string>
using namespace std;

int main() {
  string name = "John";
  int age = 35;
  double height = 6.1;

  cout << name << " is " << age << " years old and " << height << " feet tall.";
  return 0;
}
```

## Outro

**Say:** Two things to take with you. A declaration is a reservation: type, name, value, and the type decides the size and shape of the box. And put a value in on the same line you declare it, every time, because an empty box holds garbage, not zero. Next time: what happens when a variable holds the address of another variable. That's a pointer, and it's the idea the rest of the course is built on.

**Screen:** final program, terminal showing `John is 35 years old and 6.1 feet tall.`

---

*Timing guide: cold open 0:45 · lines 1–4 about 2:00 · experiment 0:40 · outro 0:30. Around four minutes.*
