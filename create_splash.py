import struct
import zlib

def create_png(width, height, color_rgb):
    """Create a simple solid color PNG."""
    def png_chunk(chunk_type, data):
        chunk_len = struct.pack('>I', len(data))
        chunk_crc = struct.pack('>I', zlib.crc32(chunk_type + data) & 0xffffffff)
        return chunk_len + chunk_type + data + chunk_crc

    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'

    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr = png_chunk(b'IHDR', ihdr_data)

    # IDAT chunk (raw image data)
    raw_data = b''
    for _ in range(height):
        raw_data += b'\x00'  # filter byte
        for _ in range(width):
            raw_data += bytes(color_rgb)

    compressed = zlib.compress(raw_data)
    idat = png_chunk(b'IDAT', compressed)

    # IEND chunk
    iend = png_chunk(b'IEND', b'')

    return signature + ihdr + idat + iend

# Create a 512x512 dark blue logo placeholder
png_data = create_png(512, 512, (26, 26, 46))

with open('assets/splash_logo.png', 'wb') as f:
    f.write(png_data)

print("Created splash_logo.png")
