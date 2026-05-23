/**
 * @file armv8m_barrier.h
 * @brief Armv8-M memory and instruction synchronization barrier helpers.
 *
 * These inline helpers wrap architectural DMB/DSB/ISB instructions used when
 * programming system registers whose effects must be observed in order.
 */

#pragma once


static inline void nexus_arch_dmb(void)
{
	__asm volatile ("dmb sy" ::: "memory");
}

static inline void nexus_arch_dsb(void)
{
	__asm volatile ("dsb sy" ::: "memory");
}

static inline void nexus_arch_isb(void)
{
	__asm volatile ("isb sy" ::: "memory");
}
