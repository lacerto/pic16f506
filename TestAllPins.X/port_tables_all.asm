#include "p16F506.inc"

;#define LOW_CURRENT

    global GetCount, PortCTable, PortBTable

PORT_TABLES CODE

#ifdef LOW_CURRENT
GetCount:
    retlw 0x12

PortCTable:
    addwf PCL, F
    dt b'00000001'
    dt b'00000010'
    dt b'00000100'
    dt b'00001000'
    dt b'00010000'

    dt b'00100000'
    dt b'00000000'
    dt b'00000000'
    dt b'00000000'
    dt b'00000000'

    dt b'00000000'
    dt b'00000000'
    dt b'00000000'
    dt b'00100000'
    dt b'00010000'

    dt b'00001000'
    dt b'00000100'
    dt b'00000010'

PortBTable:
    addwf PCL, F
    dt b'00000000'
    dt b'00000000'
    dt b'00000000'
    dt b'00000000'
    dt b'00000000'

    dt b'00000000'
    dt b'00000001'
    dt b'00000010'
    dt b'00000100'
    dt b'00010000'

    dt b'00000100'
    dt b'00000010'
    dt b'00000001'
    dt b'00000000'
    dt b'00000000'

    dt b'00000000'
    dt b'00000000'
    dt b'00000000'

#else

GetCount:
    retlw 0x10

PortCTable:
    addwf PCL, F
    dt b'00000001'
    dt b'00000011'
    dt b'00000111'
    dt b'00001111'
    dt b'00011111'

    dt b'00111111'
    dt b'00111111'
    dt b'00111111'
    dt b'00111111'
    dt b'00111111'

    dt b'00111111'
    dt b'00001111'
    dt b'00000111'
    dt b'00000011'
    dt b'00000001'

    dt b'00000000'

PortBTable:
    addwf PCL, F
    dt b'00000000'
    dt b'00000000'
    dt b'00000000'
    dt b'00000000'
    dt b'00000000'

    dt b'00000000'
    dt b'00000001'
    dt b'00000011'
    dt b'00000111'
    dt b'00010111'

    dt b'00010111'
    dt b'00010111'
    dt b'00010110'
    dt b'00010100'
    dt b'00010000'

    dt b'00000000'

#endif

    END