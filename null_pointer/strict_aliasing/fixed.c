#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <arpa/inet.h>

#define MAX_LEN 64

void parse_packet(char *buf) {
    uint32_t len_field;

    /* CORRECT: use memcpy to read raw bytes into a typed variable.
       memcpy is defined to work regardless of pointer types — it is
       the standard-blessed way to type-pun in C. No aliasing violation,
       no stale cache, no undefined behavior.                           */
    memcpy(&len_field, buf, sizeof(uint32_t));

    printf("raw value before ntohl : %u\n", len_field);

    len_field = ntohl(len_field);

    printf("value after ntohl : %u\n", len_field);

    /* SECURITY CHECK — now always reads the correct post-swap value */
    if (len_field > MAX_LEN) {
        printf("PACKET DROPPED (len=%u > MAX_LEN=%u) -- SECURE\n",
               len_field, MAX_LEN);
        return;
    }

    printf("processing packet of length %u\n", len_field);
}

int main(void) {
    char packet[68];
    memset(packet, 'A', sizeof(packet));

    packet[0] = 0x00;
    packet[1] = 0x00;
    packet[2] = 0x01;
    packet[3] = 0x00;   /* 256 in big-endian */

    printf("Strict aliasing demo (code fixed)\n");
    printf("Packet length field in network order: 256 (should be dropped)\n\n");

    parse_packet(packet);
    return 0;
}
