# 🐚 `csh` - A Custom Shell in C

Welcome to **`csh`**, a custom shell written in C that brings the power of basic UNIX-like commands right to your fingertips! Designed to provide a smooth and intuitive command-line experience, `csh` supports essential file and text manipulation commands, making it a great project for exploring low-level system programming.

## ✨ Features

### Built-in Commands:
- **`ls`** - List directory contents
- **`cat`** - Display file contents
- **`grep`** - Search for patterns within files
- **`wc`** - Count words, lines, and characters in files
- **`mv`** - Move or rename files
- **`rm`** - Remove files
- **`date`** - Display the current date and time
- **`calc`** - Perform arithmetic calculations
- **`todo`** - Manage a to-do list
- **`touch`** - Create a file
- **`df`** - Displays disk memory usage
- **`head`** - Output first 5 lines of a file
- **`tail`** - Output last 5 lines of a file
- **`find`** - Search for patterns within filenames

## 🚀 Getting Started

To try out `Csh`, clone the repository and compile the code as follows:

```bash
# Clone the repository
git clone https://github.com/rzeta-10/OS-Project.git
cd Project2_Csh

# Compile the shell program
make clean
make

# Run the shell
./cshell
```

![shell output](images/csh.jpeg)

## 🛠️ Usage

Once `csh` is running, you can start using the supported commands just as you would in a typical UNIX shell. Here are a few examples with images of each command in action:


---

You can use the `Up Arrow (↑)` and `Down Arrow (↓)` keys to navigate through previously executed commands

### `ls` - List directory contents
```bash
ls
```
![ls command output](images/ls.jpeg)

### `ls -l` - List directory contents with detailed information
```bash
ls -l
```
![ls -l command output](images/ls%20-l.jpeg)

### `cat` - Display contents of a file
```bash
cat filename.txt
```
![cat command output](images/cat.jpeg)

### `grep` - Search for patterns within files
```bash
grep 'pattern' filename.txt
```
![grep command output](images/grep.jpeg)

### `wc` - Count lines, words, and characters in a file
```bash
wc filename.txt
```
![wc command output](images/wc.jpeg)

---

### `mv` - Move or rename a file
```bash
mv oldname.txt newname.txt
```
![mv command output](images/mv.jpeg)

### `rm` - Delete a file
```bash
rm filename.txt
```
![rm command output](images/rm.jpeg)

### `date` - Display the current date and time
```bash
date
```
![date command output](images/datetime.jpeg)

### `calc` - Perform arithmetic calculations
```bash
calc 10 + 5
calc 15 / 3
calc 7 * 8
```
![calc command output](images/calc.jpeg)

### `todo` - Manage a to-do list
```bash
todo add "Finish homework"
todo list
todo delete 1
```
![todo command output](images/todo.jpeg)

### `touch` - create a file
```bash
touch filename 
```
![touch command output](images/touch.jpeg)


### `df` - Displays disk memory usage
```bash
df 
```
![df command output](images/df.jpeg)

### `head` - output first 5 lines
```bash
head filename
```
![head command output](images/head.jpeg)

### `tail` - output last 5 lines
```bash
tail filename
```
![tail command output](images/tail.jpeg)

### `find` - search for patterns within filename
```bash
find . "pattern"
```
![find command output](images/find.jpeg)

## 📚 Project Structure

- **`main.c`** - Launches a new terminal instance and executes the custom shell `shell.c`
- **`shell.c`** - Core implementation of the shell.
- **`Makefile`** - For building the project with ease.
- **`README.md`** - You’re reading it!

## 🤖 Built With

- **C** - For low-level system programming and managing system calls.
- **UNIX System Calls** - For executing commands, handling files, and managing processes.

## 💡 Why `csh`?

This project is a deep dive into understanding how a shell operates at a fundamental level, making it a great hands-on experience with system-level programming. It’s compact, practical, and covers essential shell functionality, perfect for anyone curious about what goes on behind the scenes of a command-line interface.

---
