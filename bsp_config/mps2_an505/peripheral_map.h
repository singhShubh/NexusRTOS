#pragma once

/*
 * Arm MPS2+ AN505 FPGA image board-level peripheral address map.
 *
 * Core-private Armv8-M system registers such as NVIC, SCB, MPU, and SAU are
 * handled by the architecture layer. Secure-only PPC/MPC controller addresses
 * are intentionally kept in the secure BSP.
 */

#define PERIPH_WINDOW_SIZE      0x00001000UL

/* APB PPC0: timers. */
#define TIMER0_BASE             0x40000000UL
#define TIMER0_SIZE             PERIPH_WINDOW_SIZE
#define TIMER1_BASE             0x40001000UL
#define TIMER1_SIZE             PERIPH_WINDOW_SIZE
#define DUALTIMER_BASE          0x40002000UL
#define DUALTIMER_SIZE          PERIPH_WINDOW_SIZE

/* APB PPC1: 32 kHz timer. */
#define S32KTIMER_BASE          0x4002F000UL
#define S32KTIMER_SIZE          PERIPH_WINDOW_SIZE

/* Watchdogs. */
#define NSWATCHDOG_BASE         0x40081000UL
#define NSWATCHDOG_SIZE         PERIPH_WINDOW_SIZE

/* APB PPC expansion 1: serial buses and UARTs. */
#define UART0_BASE              0x40200000UL
#define UART0_SIZE              PERIPH_WINDOW_SIZE
#define UART1_BASE              0x40201000UL
#define UART1_SIZE              PERIPH_WINDOW_SIZE
#define UART2_BASE              0x40202000UL
#define UART2_SIZE              PERIPH_WINDOW_SIZE
#define UART3_BASE              0x40203000UL
#define UART3_SIZE              PERIPH_WINDOW_SIZE
#define UART4_BASE              0x40204000UL
#define UART4_SIZE              PERIPH_WINDOW_SIZE
#define SPI0_BASE               0x40205000UL
#define SPI0_SIZE               PERIPH_WINDOW_SIZE
#define SPI1_BASE               0x40206000UL
#define SPI1_SIZE               PERIPH_WINDOW_SIZE
#define I2C0_BASE               0x40207000UL
#define I2C0_SIZE               PERIPH_WINDOW_SIZE
#define I2C1_BASE               0x40208000UL
#define I2C1_SIZE               PERIPH_WINDOW_SIZE
#define SPI2_BASE               0x40209000UL
#define SPI2_SIZE               PERIPH_WINDOW_SIZE
#define SPI3_BASE               0x4020A000UL
#define SPI3_SIZE               PERIPH_WINDOW_SIZE
#define SPI4_BASE               0x4020B000UL
#define SPI4_SIZE               PERIPH_WINDOW_SIZE
#define I2C2_BASE               0x4020C000UL
#define I2C2_SIZE               PERIPH_WINDOW_SIZE
#define I2C3_BASE               0x4020D000UL
#define I2C3_SIZE               PERIPH_WINDOW_SIZE

/* APB PPC expansion 2: board control peripherals. */
#define SCC_BASE                0x40300000UL
#define SCC_SIZE                PERIPH_WINDOW_SIZE
#define I2S_AUDIO_BASE          0x40301000UL
#define I2S_AUDIO_SIZE          PERIPH_WINDOW_SIZE
#define FPGAIO_BASE             0x40302000UL
#define FPGAIO_SIZE             PERIPH_WINDOW_SIZE

/* AHB PPC expansion 0: VGA and GPIO. */
#define GPIO0_BASE              0x40100000UL
#define GPIO0_SIZE              PERIPH_WINDOW_SIZE
#define GPIO1_BASE              0x40101000UL
#define GPIO1_SIZE              PERIPH_WINDOW_SIZE
#define GPIO2_BASE              0x40102000UL
#define GPIO2_SIZE              PERIPH_WINDOW_SIZE
#define GPIO3_BASE              0x40103000UL
#define GPIO3_SIZE              PERIPH_WINDOW_SIZE
#define VGA_BASE                0x41000000UL
#define VGA_SIZE                0x00140000UL

/* Ethernet is not controlled by an AHB PPC expansion slot. */
#define ETH_BASE                0x42000000UL
#define ETH_SIZE                0x00100000UL

/* AHB PPC expansion 1: DMA controllers. */
#define DMA0_BASE               0x40110000UL
#define DMA0_SIZE               PERIPH_WINDOW_SIZE
#define DMA1_BASE               0x40111000UL
#define DMA1_SIZE               PERIPH_WINDOW_SIZE
#define DMA2_BASE               0x40112000UL
#define DMA2_SIZE               PERIPH_WINDOW_SIZE
#define DMA3_BASE               0x40113000UL
#define DMA3_SIZE               PERIPH_WINDOW_SIZE
