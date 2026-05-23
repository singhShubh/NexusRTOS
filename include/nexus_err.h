#pragma once

typedef enum {
    NEXUS_OK                 = 0,
    NEXUS_ERR_GENERIC        = 1,
    NEXUS_ERR_INVALID_ARG    = 2,
    NEXUS_ERR_NO_MEMORY      = 3,
    NEXUS_ERR_NOT_FOUND      = 4,
    NEXUS_ERR_ALREADY_EXISTS = 5,
    NEXUS_ERR_BUSY           = 6,
    NEXUS_ERR_TIMEOUT        = 7,
    NEXUS_ERR_NOT_SUPPORTED  = 8,
    NEXUS_ERR_PERMISSION     = 9,
    NEXUS_ERR_STATE          = 10,
    NEXUS_ERR_IO             = 11,
} nexus_err_t;
