# Demystifying Compilers

The lowest level of computer programming: assembly, BIOS programming and juggling around limited memory exists for their endless versatility and potential for optimization. These qualities are required to get a computer running on bare necessities of limited registers, memories, etc. The obvious downside is it's painstaking process of simply getting anything done. Everything needs to be explicitly instructed, and an eternity of code is needed to get the simplest of task done (it should, honestly, given the complexity of even the simplest tasks). Another drawback is the compatibility: assmebly languages differ substantially depending on the machine they are running on: that is, their CPU architecture. Porting assembly code designed for ARM to RISC processors is not a trivial task. But obviously engineers grew tired of it, and began writing in higher-level languages which abstract away the complicated details of low-level development. For this, they looked to languages like C/C++, Fortran, etc. These languages utilize what are called compilers, which look at the code and convert them into executable files which the computer can understand.

## C Compilation

The following code generates an object file:

> gcc -ffreestanding -c basic.c -o basic.o

Object files are essentially annotated machine code, with certain labels not needed for execution kept so that we have more options on how to put together these files later on. Using the `objdump` command with the `-d` flag gives us a good look at the entire file.

From there, executable code that can be run on the CPU is attained by using a **linker**, which as the name suggests, links together multiple object files into one binary file. In the process, relative addresses written in the object files are converted to absolute addresses within the aggregated machine code. For example, call <big_func> may be converted into 0x1234, which is where the linker placed the instructions of the routine specified by big_func.

But let's not get ahead of ourselves. Say we only have one object file. The following command will turn it into a binary file:

> ld -o foo.bin -Ttext 0x0 --oformat binary foo.o

The `ld` command is the linker command. It is designed specifically for combining several object files and libraries, resolving references, and producing an ouput file (as the man page says, anyways). The above command can be altered to output executable files in various formats. Some formats will retain meta data from the inputted object files. Why is that? Mostly so operating systems make use of it to decide how certain applications are to be loaded into memory, or debugging. Instead of a process crashing at 0x12345678, knowing that a process crashed in function my_func, file foo.c, on line 3, is much more useful for debugging.

With all that said, Operating Systems won't give a fuck. That's why raw binary will suffice for writing OS. So that's the `--oformat binary` option. The `--Ttext 0x0` option, tells the compiler how to offset the addresses of our code, when converting these addresses into an absolute set of addresses. **This option becomes important when loading the kernel code into the memory**.

So now, we are able to create raw binary files from C code, which could be run by the CPU. Machine code instructions are very much like assembly code. A simple disassembler will allow you to view any binary file in assembly format. **Note that given a binary file minus the original code, reading assembly can reveal much about the software and allow reverse engineering, making use of some meta data the developer may have left inside, which they most always do**. However, some bytes reserved for data may appear as assembly instructions as well, so sometimes some instructions may be confusing.

## Making the Connection Between C Code and Resulting Binary

Taking a look at a compiled binary for the first time will be confusing for any programmer. All the familiar syntaxes are gone, and they're replaced with a wall of undecipehrable symbols. Making the even the smallest connection, however, between a line of code and the resulting binary instruction set can make the binary file that much easier to read. 

### Basics

The 3 columns from left to right, represent the offset of the instruction, the machine code, and the assembly instruction equivalent to that machine code. One glance at the instruction set will tell you that no matter how simple the original code is, the assembly ends up messing with the stack somehow: specifically, the two pointers responsible for the stack (ebp, esp). C uses the stack for storing variables local to a function (these are discarded along with the function itself after returning). For any function, the stack's base pointer ebp's value will be changed to that of the top of the stack (esp value) via `mov ebp, esp`, which essentially creates a whole new empty stack on top of the existing stack. This is often referred to as construction the **stack frame** for that function. Once we are done executing the function, we should return the state of the stack to how it was before beginning execution of the fuction. Otherwise, the processor state will be a mess. For that purpose, the old base pointer value is stored in the stack before the function itself is called (push ebp).

When a function returns a value, you may notice that it is stored in `eax`, a general-purpose register with 32-bit space. Should another function be calling the particular function, this is where it would look for when it needs the return value (recall: this is similar to how assembly routines recieved arguments via specific registers like string printing method expecting the address of the string to be stored at register bx).

### Variable Handling

Say you have a simple function that saves an integer to a variable and returns it. This is most likely a series of assembly instructions you'll see:

> push ebp
> mov ebp, esp
> sub esp, byte +0x10
> mov dword [ebp-0x4], 0xabcd # Value of the variable
> mov eax, [ebp-0x4]
> leave
> ret

What is the compiler doing here? After establishing the stack frame for this function, it subtracts 0x10 (16) bytes from esp, the pointer pointing to the top of the stack? Recall that stack grows backwards with respect to the address. As in, subtracting 16 bytes from the stack top pointer means its expanding the stack upwards by 16 bytes. It is essentially **allocating** space for the stack. Assume we are storing an integer: which is 4 bytes (32 bits). We don't need all 16 bytes to store just an int variable, so why did it do that? Furthermore, the processor literally just used `push` to store ebp on the stack, why can't it do that again? **Because optimization**. CPUs struggle to operate when the size of the data they're messing with is not 'aligned' on the way the memory boundaries are set. C wants all variables to be properly aligned, as in it wants the variables to use up all 16 bytes for all stack elements. While this obviously leads to a waste of some memory, it still is a decent trade-off to ensure efficient computation.

Now, what does `mov dword [ebp-0x4], 0xabdc` even mean? Personally for the author, this line of instructions seemed the most intimidating at first. What it is doing is storing the variable's value in the newly allocated space on the stack, without using push due to reasons just stated. `mov` we are familiar with, but the other two we are not. Here are what they do:

- `dword`: Stands for double word, as in 4 bytes. It is explicitly stating that we are storing a double word on the stack, indicating the size of the integer value data type. We are assuming that the original code is storing a hex value of 0xabcd in the integer variable, but think about it: without `dword`, the bytes stored would be 0xabcd, which is 2 bytes. The `dword` ensures that it is saved as 0x0000abcd. In some cases it could end up as 0x000000000000abcd (8 bytes) without properly specifying them.

- `[ebp-0x4]: This is what is called **effective address computation**. It is a modern CPU shortcut. It calculates an address right there and now, based on the current address stored in the ebp register. It looks like the processor would be messing with constant values right? Only once when the code is actually run, would the value of any register be known: this instruction will be executed on runtime. But why do this when you could explictly split the instructions as follows?:

> mov eax, ebp
> sub eax, 0x4
> mov [eax], 0xabcd

Because CPU optimization is a thing. Because the earlier instruction line allows us to do all this in one instruction, the CPU is able to enjoy instruction-level-parallelism without risking data hazards.

Back to the code. 0xabcd is now stored on the stack (specifically, to occupy the first 4 bytes above the base pointer (in terms of addresses, below)). Much like we, the programmer, recognize the specific saved variable in the name of whatever we named it as (like big_var), the compiler will recognize it as ebp-0x4, AKA the first 4 bytes of the stack. We see this in the next instruction following, `mov eax, [ebp-0x4]`, which uses the previously-mentioned efficient address computation to store the value into the eax register, which, is the register referred to as the return variable to whatever called the function in our current attention.  

So now, we have left the `leave` function and the `ret` function. `leave` essentially does the equivalent to the following instruction set:

> mov esp, ebp
> pop ebp

Which, essentially is the whole ordeal of restoring the original position of the stack frame before calling the current function. Apparently though being a single instruction, in some cases `leave` isn't the most efficient choice for this purpose. That's a whole new discussion left for another time.

## Calling Functions

Now that we understand a little about how variables are treated in functions, it's time to look at how functions are treated in functions. Making a simple function in C that calls another function with an argument may consist of the following disassembled binary file:

> push ebp
> mov ebp, esp
> sub esp, byte + 0x8
> mov dword [esp], 0xdede
> call dword 0x14
> leave
> ret
> push ebp
> mov ebp, esp
> mov eax, [ebp+0x8]
> pop ebp
> ret

Wowee look at that, we can tell there's two functions being handled by the ret instruction, which is usually at the end of a function. Something new from our last set of instructions is the `call` instruction. This instructs the processor to jump to another routine, which they'll most likely return from. That's where the function calls the other function. To the computer, the secondary function being called is regarded as the instruction offset of 0x14 in the machine code. In our assumed code, we are passing an argument into the function as well. Now where is it handling that? After initializing the new stack frame, we can see 8 bytes are allocated on top of the stack, then stores the passed value, `0xdede` to that space. From there, how are they reading the value? Lets follow the code after 0x14 is called. The actual address offsets are omitted in the above lines, but the 0x14 offset line is the seond `push ebp` instruction line (8th line from the top). So we see that another stack frame is created, business as usual. Then, In the eax register, which is supposed to hold the return value, the value of the passed argument value is stored (all this stack direction bullshit is a little confusing, but recall that the ebp is figuratively pointing to the highest value of that stack frame, as stack grows downwards with respect to the address. So, the computer in this instruction is accessing outside the stackframe of the current instruction, 8 bytes out of the stack frame, to be specific. So they're essentially digging under their new stack). This makes sense, as the computer stacked the arguemnt value in the tippy top of the old stack frame, which should be right below the current stack frame. This way, the current function can access the argument.  

We just went through the common calling convention of a high-level language, C. For future reference, C pushes arguments into the stack in reverse order. The first argument is going to be on the top of the stack. Mess this up, and the program performs incorrectly and big crash.

## Pointers, Addresses, Data

**Variables are just references to allocated memory addresses**. This is a fundamental but often forgotten, and honestly an unintuitive thing to keep in mind when using high-level languages. Furthermore, these memory addresses are **allocated sufficiently to reserve enough space to accomodate their particular data type**. This disconnect is understandible, as we are, for the most part, only concerned with the value stored in those variables, more than where they are stored in memory.

But what if we care about where we store variable values then? Recall back to the BIOS work, where to write characters on screen after BIOS was no longer available, we had to store those specific values in `0xb8000`. Can we do that with C? I mean, so far the compiler has been the one deciding where variables are stored (in the stack). Some higher-level languages don't allow this to happen, as it really goes against the abstraction that high-level programming languages want to enable. But C has **pointers**. They are datatypes designed specifically for storing addresses rather than values. Pointers can be **dereferenced**, allowing reading or writing data to wherever.

Pointers are all 32-bit memory addresses. Because we write pointers to read/write specific datatypes from/to the address pointed to, however, we set a datatype for the specific pointer. "This pointer is for char, and thats a pointer for int". This ensures that we don't have to tell the pointer every time how many bytes beyond the specified address the computer should read. 

Simple syntax are the following:

- Initializing the pointer: `char* video_address = 0xb8000;` will initialize a pointer for char (single byte), pointing to the address where it will be saved. Despite the size of char datatypes, 32 bits will still be allocated for the pointer, as that's the length of the address. 

- Dereferencing: `*video_address = 'X';` will **dererence** the pointer, as in changing the value stored at an address pointed to by the pointer. The contents of that address are chnaged, not the value of the address specified in the pointer. For reference, not using the star before the varaible name will chactually store the ASCII code of 'X' in the pointer variable, which will be interpreted as an address and inevitably throw an error eventually. 

### Pointers in the Wild

In C code we often see char* variables use for strings. This has to do with the uncertainty of the total length of the data. Unlike singular characters or integers, we don't know how long strings go for. Instead of storing the value of the entire string which we don't know the size of, we use a pointer to reference the location of where the first character in the string is located. From there, the computer can work out the rest of the string. This trend can also be seen in assembly, such as when writing a module to print strings, and passed the address of the first character to a certain register. Let's take a look at how a compiler handles strings.

A toy function that simply allocates a string by initializing a pointer (`char* my_string = 'boy';`) may result in the following binary file:

> push ebp
> mov ebp, esp
> sub esp, byte +0x10
> mov dword [ebp-0x4], 0x10
> nop
> leave
> ret
> bound ebp, [edi+0x79]
> add [eax+eax],dl
> add[eax], al
> ...

`ret` my boy, always there for me. First 2 instructions as always to set up the stack frame, then 16 bytes allocated on the stack, and now...what the fuck is it doing, it's storing 0x10 in the stack? Why though? `nop`? `dec eax`? What are these men you have brought into my abode?

Recall that disassembler cannot distinguish between code and data. The data we specififed must be in that code somewhere, and is treated as code. So now we assume that beyond ret, are data treated as code, leading to the incoherent instruction set we see below. So then what is this 0x10 being stored in the stack? This must be pointing to where the data begins then. Though it is omitted, referencing the middle column of the binary and from the 0x10 offset from the beginning of the binary is where the `bound ebp, [edi+0x79]` instruction is located, marking the beginning of where hell breaks lose in the instruction set. Our string, 'boy', translates to the ASCII hex representation of 0x62, 0x6F, 0x79. The middle column tells us that those hex values are what is making up the incoherent instruction, showing that the data is indeed being interpreted as instructions. Note that also 0x0 comes after. This is consistent with the fact that C automatially adds a 0 in the end of strings, which we also did when creating a string printing routine in assembly. 

Now that you've spent some time familiarizing with basic C concepts and how C code translates to binary code, it's time to jump into writing a simple kernel.
