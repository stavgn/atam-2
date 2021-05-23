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
}

unsigned long my_get_gate_offset(gate_desc *gate) {
	return (unsigned long)(gate->offset_high << 32) + (gate->offset_middle << 16) + (gate->offset_low);
}

