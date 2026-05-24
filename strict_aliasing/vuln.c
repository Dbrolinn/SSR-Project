#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <arpa/inet.h>   /* ntohl */

#define MAX_LEN 64

/* Simulates a raw network buffer arriving with a 4-byte length field */
void parse_packet(char *buf) {
    /* TYPE PUN: treat the first 4 bytes as a uint32_t
       This is a strict aliasing violation — char* and uint32_t* are
       different types, so the compiler may cache *len_field and never
       reload it after the ntohl write                                */
    uint32_t *len_field = (uint32_t *)buf;

    printf("raw value before ntohl : %u\n", *len_field);

    /* byte-swap the length in place (network to host order) */
    *len_field = ntohl(*len_field);

    printf("value after ntohl : %u\n", *len_field);

    /* SECURITY CHECK — may compare against the PRE-swap cached value
       at -O2, making the check invisible to the compiler              */
    if (*len_field > MAX_LEN) {
        printf("PACKET DROPPED (len=%u > MAX_LEN=%u)\n",
               *len_field, MAX_LEN);
        return;
    }

    /* This should never run for oversized packets */
    printf("processing packet of length %u  <-- SECURITY BYPASSED\n",
           *len_field);
}

int main(void) {
    /* Craft a packet whose length field is 256 in network byte order
       On a little-endian machine: 256 = 0x00000100
       In network (big-endian) bytes: 0x00, 0x00, 0x01, 0x00          */
    char packet[68];
    memset(packet, 'A', sizeof(packet));

    /* Write 256 in big-endian into first 4 bytes */
    packet[0] = 0x00;
    packet[1] = 0x00;
    packet[2] = 0x01;
    packet[3] = 0x00;   /* = 256 in big-endian */

    printf("Strict aliasing demo \n");
    printf("Packet length field in network order: 256 (should be dropped)\n\n");

    parse_packet(packet);
    return 0;
}
