// Note: most libraries used commonly in C are not available at this point in time due to -ffreestanding flag. The select few that are still available for use (ones that are more part of the compiler than the C library distribution) are called below.
#include <stdbool.h> // bool data type 
#include <stddef.h> // size_t and NULL usage
#include <stdint.h> // intx_t and uint_t datatypes, used often in OS dev

/* Using macros, check to see if compiler thinks you're targetting the wrong operating system. The below code will ensure at compile time. */
#if defined(__linux__) // ifdef directive, if __linux__ is defined, execute the below code
#error "You're not using a cross-compiler, and you'll probably explode"
#endif

/* Also make sure target is 32-bit ix86 */
#if !defined(__i386)
#error "ix86-elf compiler is needed to compile this"
#endif

/* Hardware text mode color constants */
enum vga_color {
	VGA_COLOR_BLACK = 0,
  	VGA_COLOR_BLUE = 1,
  	VGA_COLOR_GREEN = 2,
  	VGA_COLOR_CYAN = 3,
 	VGA_COLOR_RED = 4,
 	VGA_COLOR_MAGENTA = 5,
 	VGA_COLOR_BROWN = 6,
 	VGA_COLOR_LIGHT_GREY = 7,
 	VGA_COLOR_DARK_GREY = 8,
 	VGA_COLOR_LIGHT_BLUE = 9,
 	VGA_COLOR_LIGHT_GREEN = 10,
 	VGA_COLOR_LIGHT_CYAN = 11,
 	VGA_COLOR_LIGHT_RED = 12,
 	VGA_COLOR_LIGHT_MAGENTA = 13,
 	VGA_COLOR_LIGHT_BROWN = 14,
 	VGA_COLOR_WHITE = 15,
};

// Note about static inline: 
// Inline functions are functions with relatively small definition, which can basically be substituted where the function call is made. So, insert the entirety of the function defintion "inline" at time of compilation. (This is entirely up to the compiler, as it merely a sort of hint to consider when compiling.) This is done to optimize execution by cutting away overhead to call functions. There are many more factors contributing to this overhead, thus it's up to the compiler to actually substitude it inline in the end. Furthermore, based on compilation optimization setting set beforehand, this command could serve no purpose. One could force to inline, by declaring the always_inline attribute as well.
// Static functions in C (not to be confused with ones in C++) are made to only be called in the file where they are declared. It is essentially restricting access to the function from outside the file.
// "uint8_t" is the equivalent of "unsigned char", which is an idea "basic variable" to store 8 bits worth of information
static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg)
{
	return fg | bg << 4; // not sure why bit shift has more priority than bitwise operation here, because intuitively I assume bg is being shifted into the top 4 significant bits of the return value, and 4 bits of fg being fit into the bottom 4 bits with the bitwise or. 
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) // not entirely sure why unsigned char is used as an argument instead of uint8_t, when it's known to be the less reliable of the two, because it's not always guarenteed to be 8 bits depending on the system being run
{
	return (uint16_t) uc | (uint16_t) color << 8; // asme as above function, we see shift holding more precedence than bitwise or despite it being on the right... because from my understanding color is assumed to be the top 8 sig bits, with uc as bottom 8 char
}

size_t strlen(const char* str) // size_t is an unsigned integral data type, mostly used in headers. basically represents size of objects in bytes. sizeof() operator returns data in this type. apparently can handle the biggest object in host system. const char* makes the string immutable, but the pointer itself stays mutable. char* const would conversely make the pointer immutable, but string mutable. conat char* const would make both immutable.
{
	size_t len = 0;
	while(str[len])
		len++;
	return len;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

void terminal_initialize(void)
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	terminal_buffer = (uint16_t*) 0xB8000; // this is the address location in memory where vga display characters are to be stored
	for (size_t y=0;y<VGA_HEIGHT;y++){
		for(size_t x=0;x<VGA_WIDTH;x++){
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}

void terminal_setcolor(uint8_t color)
{
	terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y)
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

void terminal_putchar(char c)
{
	if(c=='\n'){
		terminal_column = 0;
		terminal_row++;
	} else{
		terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
		if(++terminal_column == VGA_WIDTH){
			terminal_column = 0;
			if(++terminal_row == VGA_HEIGHT){
				terminal_row = 0;
			}
		}
	}
}

void terminal_write(const char* data, size_t size)
{
	for(size_t i=0;i<size;i++)
		terminal_putchar(data[i]);
}

void terminal_writestring(const char* data)
{
	terminal_write(data, strlen(data));
}

void kernel_main(void)
{
	terminal_initialize();
	terminal_writestring("Hey, kernel here\nLine break too\n");
}
