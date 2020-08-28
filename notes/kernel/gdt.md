# The Global Descriptor Table

The GDT is essential to the operation of a computer beyond the BIOS stage of booting. In 16-bit systems, **segment-based addressing** (prefixing addresses with groups of data that serve a similar purpose to enable programmers to reference a larger range of addressesthan normal 16-bit addressing would allow). Storing value of the ax register at address 0x4fe56 without segment-based addressing would be impossible, as the largest value a programmer could speicfy is 0xffff, resulting in the instruction:

> mov [0xffff], ax

Which is much too small compared to 0x4fe56. Now, lets try using a segment register:

> mov bx, 0x4000
> mov es, bx
> mov [es:0xfe56], ax

This will allow us to access 0x4fe56 (refer back to segment-based addressing for a more in-depth recap). Basically, the idea is segmenting memory into sections that handle similar types of data, and using offsets specified for that section to access the memory inside it. The GDT follows the same fundamental idea, except made much more versatile. While the original segment-based addressing conssits of multiplying the segment register by 16 and adding it to the offset, in GDT the segment register becomes the register to a **segment descriptor** in the GDT.

## The Segment Descriptor

THe SD is an 8-byte strcture defining a segment:

- **Base Address** (32 bits): Defines where the segment begins in physical memory
- **Segment Limit** (20 bits): Size of the segment
- **Flags** (variable length): Assortment of flags to tell the CPU how to handle that specific segment. Examples include things such as priviledge level of code, read/write-only, etc

Given those details, the actual segment descriptor is a little unsettling, as the base address and segment limit are scattered across the structures after being fragmented (divided and mixed amongst each other). The reason for this is largely unknown, with possible reasons being to accomodate for specific CPU hardware structures, or someone's sick joke. Now, I could read the full extent of details about segment descriptors in Intel's Developer Manual, but that goes well beyond the scope of running 32-bit mode.

## Flat Model

The **flat model** is the simplest configuration which one could set up their segment registers, as specified by Intel. The gist is setting up 2 overlapping segments covering the full 4GB (32-bit addressable) memory. One will specify code, and the other data. Yes, when I said overleapping, I mean they step on each other like that, and don't care about protecting each other from one-another. No memory protection, no paging, no virtualization. Segment descriptors may be altered later on, and it's best practice to keep things as simple as possible first. 

Furthermore, the first entry of the GDT must be an **invalid null descriptor**, as in 8 zero bytes. We do this to catch mistakes, such as when forgetting to set the value of a segment register before accessing a certain address. Often when that happens the segment registers may be set to 0x0 and be forgotten to be updated after switching to protected mode. Trying to address with the null descriptor will lead to the CPU raising an exception, causing a CPU interrupt.

## Segment Specifications

With the logic of the flat model, there will only be 2 segments: code and data. Each will have their respective descriptors. The details are as follows, along with the explanations for flags set:

### Code Segment

- Base: 0x0
- Limit: 0xfffff
- Present (=1): As the segment is present in memory. This flag is used for virtual memory
- Priviledge (=0): 0 being the highest priviledge based on the ring priviledge model
- Descriptor Type (=1): 1 for code/data segment. 0 is used for traps, which relate to interrupt handling.
- Type:
	- Code (=1): To indicate that this is a code segment
	- Conforming (=0): By setting 0 to indicate not conforming, code in segments with lower priviledge can't call this code. Key memory protection feature.
	- Readable (=1): Set to readable, 0 if exec-only. Readable allows us to read constants defined in code.
	- Accessed (=0): For debugging purposes. CPU sets this bit when accessing the segment.
- Other Flags:
	- Granularity (=1): When set, it multiplies the limit by 4K (16*16*16), turning it from 0xfffff to 0xfffff000, resulting in a 3 hex digit shift to the left, spanning to 3GB to memory.
	- 32-bit default (=1): Set as segment will hold 32-bit code. Otherwise 0 would set it for 16-bit code. This flag will determine the default data unit size for operations, such as `push 0x4`, which will be expanded to 32-bit number.
	- 64-bit code segment (=0): We won't use this for obvious reasons
	- AVL (=0): Mainly for debugging, won't be used this time.

### Data Segment

The flat model is simple, and data segment will mostly have the same flag values as the code segment, except for the following:

- Code (=0): Not code, data.
- Expand down (=0): This has to do with how the CPU handles the way stack is handled in the entire segment. It will swap around where the stack can grow and where valid memory is. This goes into advanced OS definition by Intel, so it's better to leave this for later.
- Writeable (=1): Allows the data segmetn to be written to. Otherwise read-only

So, compared to 16-bit real mode, a lot more options are available. Intuitively there seems to be a lot more going on under the surface than the 16-bit mode that seemed pretty bare-boned. 

## Coding the GDT

So all the concepts seem pretty intricate, but how do we actually represent these rules as code?

Assembly defines variables with directive such as `db` (defining a single byte), `dw` (word, double byte), `dd` (doubleword, 4 bytes). These will be used to place explicitly the specified byte values throughout the entirety of the GDT. Furthermore, the CPU needs to know how long the GDT is in addition to where it is. For that reason, instead of going through the trouble of informing the CPU of multiple values, we give it the address of the **GDT Descriptor**, which describes the GDT. The GDT Descriptor is a 6-byte structure containing 16 bits representing the GDT size, and 32 bits representing the GDT address.

Something that can't be stressed enough is the importance of **commenting your code**. Especially for complex data structures, this will make the difference between being able to kind of read your code barely with maximum effort, or just keeling over and dying.

Essentially, assembly are representation of binary values in coherent symbols. Literally unloading variables on the assembly file will be the only way to define it. Along with the plethera of raw hex values hard-coded into the assembly file, we will mark respective parts of the code, such as gdt_code/gdt_data to represent where in the binary the segment descriptors for code and data segments reside. Useful constants will also be defined.
