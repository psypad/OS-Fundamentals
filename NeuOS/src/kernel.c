#include "kernel.h"
#include <stdint.h>

void kernel_main(){
    //uint16_t* video_mem = (uint16_t*)(0xB8000);
    //video_mem[0] = 0x0341;

    char* videoIter  = (char*)(0xB8000);

    char vec[24] = {'H', 3 ,'E', 3, 'L', 3 ,'L', 3, 'L', 3, 'O', 3, ' ', 3, 'W', 3, 'O', 3, 'R', 3, 'L', 3, 'D', 3};

    for(int i = 0; i < 25;i++){
        videoIter[i] = vec[i];
    }

}