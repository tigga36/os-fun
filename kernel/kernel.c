void main(){
	// Set pointer to a character
	char* video_memory = (char*) 0xb8000; // Point the pointer to first text cell of memory so that it prints to the top left of the screen
	// Set value of the pointed address to a character so that it prints that character on the top left of the screen
	*video_memory = 'X';
}
