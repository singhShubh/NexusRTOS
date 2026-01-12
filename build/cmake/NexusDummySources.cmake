function(nexus_generate_dummy_sources out_var)
    set(_dummy_entry "${CMAKE_BINARY_DIR}/generated/nexus_dummy_entry.c")
    set(_dummy_gateway "${CMAKE_BINARY_DIR}/generated/nexus_dummy_secure_gateway.c")

    file(WRITE "${_dummy_entry}" [=[
        __attribute__((used)) int nexus_dummy_entry(void) {
            for (;;) {
                __asm__ volatile ("nop");
            }
            return 0;
        }
    ]=])

    file(WRITE "${_dummy_gateway}" [=[
        __attribute__((used)) int nexus_secure_service_dispatch(int svc_id, void *arg) {
            (void)svc_id;
            (void)arg;
            return 0;
        }
    ]=])

    set(${out_var} "${_dummy_entry};${_dummy_gateway}" PARENT_SCOPE)
endfunction()
