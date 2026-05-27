#include <stdio.h>
#include <string.h>
#include <stdint.h>

// Para forçar o compilador a não fazer inline
#define NOINLINE __attribute__((noinline))

/* * A Estrutura Vulnerável
 * header: 1 byte
 * PADDING: 3 bytes inseridos pelo compilador (para alinhar o int a 4 bytes)
 * session_id: 4 bytes
 * Total: 8 bytes
 */
struct NetworkPacket {
    uint8_t header;
    uint32_t session_id;
};

// Simula o processamento de uma chave secreta que deixa rasto na stack
NOINLINE void process_secret_key() {
    // Usamos o padrão hexadecimal para a string "SECR" (Secret) repetida
    // 0x52434553 em Little Endian = 'S', 'E', 'C', 'R'
    volatile uint32_t secret_key[4] = {0x52434553, 0x52434553, 0x52434553, 0x52434553};
}

// O Cenário Vulnerável (iniciar campo a campo)
NOINLINE void transmit_packet_insecure() {
    struct NetworkPacket pkt; // Alocada no mesmo sítio da stack que a secret_key

    pkt.header = 0xAA;               // Inicializa 1 byte
    pkt.session_id = 0x12345678;     // Inicializa 4 bytes

    printf("[VULNERÁVEL] Inicialização manual campo a campo:\n");
    printf("Tamanho da struct: %zu bytes\n", sizeof(pkt));
    
    // dump da memória em raw hexadecimal
    unsigned char *raw_memory = (unsigned char *)&pkt;
    printf("Raw Memória: ");
    for (size_t i = 0; i < sizeof(pkt); i++) {
        printf("%02X ", raw_memory[i]);
    }
    printf("\n\n");
}

// mitigação A: Memset completo (A Abordagem Padrão)
NOINLINE void transmit_packet_secure_memset() {
    struct NetworkPacket pkt;
    
    // zera toda a memória alocada, incluindo o padding invisível
    memset(&pkt, 0, sizeof(pkt)); 

    pkt.header = 0xAA;
    pkt.session_id = 0x12345678;

    printf("[SEGURO] Mitigação com memset:\n");
    unsigned char *raw_memory = (unsigned char *)&pkt;
    printf("Raw Memória: ");
    for (size_t i = 0; i < sizeof(pkt); i++) {
        printf("%02X ", raw_memory[i]);
    }
    printf("\n\n");
}

int main() {
    printf("=== Teste de Fuga de Informação via Struct Padding ===\n\n");
    
    // preparamos a armadilha enchendo a stack com dados sensíveis
    process_secret_key();
    // a estrutura é alocada e dá leak dos dados através do padding
    transmit_packet_insecure();

    // repetimos o processo para a mitigação
    process_secret_key();
    transmit_packet_secure_memset();

    return 0;
}