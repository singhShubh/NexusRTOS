#pragma once

#include <stdint.h>

/*
 * IRQ domain assignment used by the BSP IRQ table to declare whether
 * each peripheral interrupt is handled in the secure or non-secure world.
 * Consumed by the BSP platform init path and shared upward to boot and
 * kernel layers.
 */
typedef enum {
    NEXUS_IRQ_DOMAIN_SECURE     = 0,
    NEXUS_IRQ_DOMAIN_NONSECURE  = 1,
} nexus_irq_domain_t;

/*
 * Per-IRQ descriptor stored in the board IRQ table.
 *
 * irq_n    : IRQn value (negative for core exceptions, >=0 for peripheral).
 * name     : human-readable identifier, useful for debug/logging.
 * domain   : secure or non-secure ownership.
 * priority : NVIC priority value to be applied during platform init.
 */
typedef struct {
    int32_t             irq_n;
    const char         *name;
    nexus_irq_domain_t  domain;
    uint32_t            priority;
} nexus_irq_desc_t;


typedef enum {
	NEXUS_MEM_TYPE_CODE,
	NEXUS_MEM_TYPE_DATA,
	NEXUS_MEM_TYPE_HEAP,
	NEXUS_MEM_TYPE_STACK,
	NEXUS_MEM_TYPE_SHARED,
	NEXUS_MEM_TYPE_TASK,
	NEXUS_MEM_TYPE_DEVICE,
} nexus_mem_type_t;


typedef enum {
	NEXUS_MEM_PERM_NONE,
	NEXUS_MEM_PERM_READ,
	NEXUS_MEM_PERM_WRITE,
	NEXUS_MEM_PERM_EXEC,
} nexus_mem_perm_t;


typedef enum {
    NEXUS_MEM_DOMAIN_SECURE,
    NEXUS_MEM_DOMAIN_NONSECURE,
} nexus_mem_domain_t;


typedef enum {
	NEXUS_MEM_ATTR_NORMAL,
	NEXUS_MEM_ATTR_WB,
	NEXUS_MEM_ATTR_WT,
	NEXUS_MEM_ATTR_WC,
	NEXUS_MEM_ATTR_DEVICE,
} nexus_mem_attr_t;


typedef enum {
	NEXUS_MEM_OWNER_KERNEL,
	NEXUS_MEM_OWNER_USER,
	NEXUS_MEM_OWNER_SHARED,
} nexus_mem_owner_t;


typedef struct {
	uintptr_t addr;
	uintptr_t size;
	const char* name;
	nexus_mem_perm_t perm;
	nexus_mem_type_t type;
	nexus_mem_attr_t attr;
	nexus_mem_owner_t owner;
	nexus_mem_domain_t domain;
} nexus_mem_regions_desc_t;
