// A set of low-level port I/O functions, allowing us to communicate with hardware in C.
// C doesn't work well with hardware communication in vanilla, and we need to rely on inline assembly commands, which allow us to define machine code within a C function.
// Since inline assembly use the GAS syntax, which is nothing like intel assembly, it's best to get it over with and create functions to call which handles the inline assembly for us.

unsigned char port_byte_in(unsigned short port){
	// A wrapper function to read a byte from a specified port
	// "=a" (result) instructs putting the AL register value in the result variable when done
	// "d" (port) instructs to load the value of the EDX with the port variable
	unsigned char result;
	__asm__("in %%dx, %%al" : "=a" (result) : "d" (port));
	return result;
}

void port_byte_out(unsigned short port, unsigned char data){
	// Wrapper function to write a byte to a specified port
	// "a" (data) means : load EAX with data
	// "d" (port) means : load EDX with port
	__asm__("out %%al, %%dx" : :"a" (data), "d" (port));
}

unsigned short port_word_in(unsigned short port){
	// Wrapper function to read a word (double byte) from a specified port
	unsigned short result;
	__asm__("in %%dx, %%ax" : "=a" (result) : "d" (port));
	return result;
} 

void port_word_out(unsigned short port, unsigned short data){
	// Wrapper function to write a word (double byte) to a specified port
	__asm("out %%ax, %%dx" : :"a" (data), "d" (port));
}
