#!/usr/bin/env python3
import struct
import sys


def webp_size(path: str):
    data = open(path, 'rb').read()
    if len(data) < 30 or data[0:4] != b'RIFF' or data[8:12] != b'WEBP':
        raise ValueError('not a WebP RIFF file')

    offset = 12
    while offset + 8 <= len(data):
        fourcc = data[offset:offset + 4]
        size = struct.unpack_from('<I', data, offset + 4)[0]
        payload = offset + 8

        if fourcc == b'VP8X':
            if size < 10:
                raise ValueError('invalid VP8X chunk')
            w = 1 + int.from_bytes(data[payload + 4:payload + 7], 'little')
            h = 1 + int.from_bytes(data[payload + 7:payload + 10], 'little')
            return w, h

        if fourcc == b'VP8 ':
            chunk = data[payload:payload + size]
            marker = b'\x9d\x01\x2a'
            pos = chunk.find(marker)
            if pos < 0 or pos + 7 > len(chunk):
                raise ValueError('VP8 frame header not found')
            w = struct.unpack_from('<H', chunk, pos + 3)[0] & 0x3FFF
            h = struct.unpack_from('<H', chunk, pos + 5)[0] & 0x3FFF
            return w, h

        if fourcc == b'VP8L':
            chunk = data[payload:payload + size]
            if len(chunk) < 5 or chunk[0] != 0x2F:
                raise ValueError('invalid VP8L header')
            bits = int.from_bytes(chunk[1:5], 'little')
            w = (bits & 0x3FFF) + 1
            h = ((bits >> 14) & 0x3FFF) + 1
            return w, h

        offset = payload + size + (size & 1)

    raise ValueError('no supported WebP image chunk found')


def main():
    if len(sys.argv) != 4:
        print(f'usage: {sys.argv[0]} FILE EXPECTED_WIDTH EXPECTED_HEIGHT', file=sys.stderr)
        return 2
    path = sys.argv[1]
    expected = (int(sys.argv[2]), int(sys.argv[3]))
    actual = webp_size(path)
    print(f'{path}: {actual[0]}x{actual[1]}')
    if actual != expected:
        print(f'expected {expected[0]}x{expected[1]}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
