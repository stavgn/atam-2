#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
    asm ("sidt %0" : "=m" (*idtr));
}

void my_load_idt(struct desc_ptr *idtr) {
    asm ("lidt %0" :: "m"(*idtr));
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
	gate->offset_low = (((1 << 16) - 1) & (addr >> (0)));
	gate->offset_middle = (((1 << 16) - 1) & (addr >> (16)));
	gate->offset_high =(((1 << 32) - 1) & (addr >> (32)));
	/*asm(
	     "movq %0, %%rax;"
	     "movw %%ax, (%1);"
	     "sar $16, %%rax;"
	     "movw %%ax, 48(%1);"
	     "sar $16, %%rax;"
	     "movl %%eax, 64(%1);"
		:
	 	: "r" (addr), "r" (gate)
		: "%rax"); */
}

unsigned long my_get_gate_offset(gate_desc *gate) {
	return (unsigned long)(gate->offset_high << 32) + (gate->offset_middle << 16) + (gate->offset_low);
	/*asm(
	     "xor %%rax, %%rax;"
	     "xor %%rbx, %%rbx;"
             "movw (%1), %%ax;"
	     "movw 48(%1), %%bx;"
	     "sal $16, %%rbx;"	
	     "add %%rbx, %%rax;"
             "xor %%rbx, %%rbx;"
	     "movl 64(%1), %%ebx;"
	     "sal $32, %%rbx;"	
	     "add %%rbx, %%rax;"
	     "mov %%rax, %0;"
		: "=r" (addr)
	 	: "r" (gate)
		: "%rax", "%rbx");*/
}
