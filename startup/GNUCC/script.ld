/*******************************************************************************
@file     stm32f4xx.ld
@author   Rajmund Szymanski
@date     29.04.2017
@brief    Linker script for STM32F407VG device with 1024KB FLASH and 192KB RAM
*******************************************************************************/

MEMORY
{
	ROM (rx)  : ORIGIN = 0x08000000, LENGTH = 1024k
	CCM (rwx) : ORIGIN = 0x10000000, LENGTH =   64k
	RAM (rwx) : ORIGIN = 0x20000000, LENGTH =  128k
/*	AUX (rwx) : ORIGIN = 0x2001C000, LENGTH =   16k
*/	BKP (rwx) : ORIGIN = 0x40024000, LENGTH =    4k
}

__ccm_start = ORIGIN(CCM);
__ccm_end   = ORIGIN(CCM) + LENGTH(CCM);
__ram_start = ORIGIN(RAM);
__ram_end   = ORIGIN(RAM) + LENGTH(RAM);

ENTRY(Reset_Handler)

SECTIONS
{
	.text :
	{
		KEEP (*(.vectors))

		*(.text   .text.*   .gnu.linkonce.t.*)
		*(.rodata .rodata.* .gnu.linkonce.r.*)
		*(.glue_7 .glue_7t)
	} > ROM

	.init : ALIGN(4)
	{
		__preinit_array_start = .;
		KEEP (*(.preinit_array))
		__preinit_array_end = .;

		__init_array_start = .;
		KEEP (*(SORT(.init_array.*)))
		KEEP (*(.init_array))
		__init_array_end = .;

		KEEP (*(.init))
	} > ROM

	.fini : ALIGN(4)
	{
		__fini_array_start = .;
		KEEP (*(.fini_array))
		KEEP (*(SORT(.fini_array.*)))
		__fini_array_end = .;

		KEEP (*(.fini))
	} > ROM

	.ARM.extab : ALIGN(4)
	{
		*(.ARM.extab* .gnu.linkonce.armextab.*)
		*(.gcc_except_table)
		*(.eh_frame_hdr)
		*(.eh_frame)
	} > ROM

	.ARM.exidx : ALIGN(4)
	{
		__exidx_start = .;
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
		__exidx_end = .;
	} > ROM

	.ccm (NOLOAD):
	{
		*(.ccm)
	} > CCM

	.bkp (NOLOAD):
	{
		*(.bkp)
	} > BKP

	.main_stack (NOLOAD): ALIGN(8)
	{
		__main_stack_start = .;
		KEEP (*(.main_stack))
		. = ALIGN(8);
		__main_stack_end = .;
	} > RAM

	__main_stack_size = SIZEOF(.main_stack);

	.data : ALIGN(4)
	{
		__data_init_start = LOADADDR(.data);

		__data_start = .;
		*(.data* .gnu.linkonce.d.*)
		. = ALIGN(4);
		__data_end = .;
	} > RAM AT > ROM

	__data_size = SIZEOF(.data);

	.bss : ALIGN(4)
	{
		__bss_start = .;
		*(.bss* .gnu.linkonce.b.*)
		*(COMMON)
		. = ALIGN(4);
		__bss_end = .;
	} > RAM AT > RAM

	__bss_size = SIZEOF(.bss);

	.proc_stack (NOLOAD): ALIGN(8)
	{
		KEEP (*(.proc_stack))
		. = ALIGN(8);
	} > RAM

	__proc_stack_size = SIZEOF(.proc_stack);

	__heap_start = LOADADDR(.proc_stack);
	__heap_end   = __ram_end - __proc_stack_size;

	__proc_stack_start = __heap_end;
	__proc_stack_end   = __ram_end;

	__initial_msp = __main_stack_size ? __main_stack_end : __heap_end;
	__initial_sp  = __proc_stack_size ? __proc_stack_end : __initial_msp;

	PROVIDE(__data_start__ = __data_start);
	PROVIDE(__data_end__   = __data_end);
	PROVIDE(__bss_start__  = __bss_start);
	PROVIDE(__bss_end__    = __bss_end);
	PROVIDE(__end__        = __bss_end);
	PROVIDE(__heap_base__  = __heap_start);
	PROVIDE(__heap_end__   = __heap_end);
	PROVIDE(__heap_base    = __heap_start);
	PROVIDE(__heap_limit   = __heap_end);
	PROVIDE(__stack        = __initial_sp);

	PROVIDE(__process_stack_start = __proc_stack_start);
	PROVIDE(__process_stack_size  = __proc_stack_size);
	PROVIDE(__process_stack_end   = __proc_stack_end);
}
