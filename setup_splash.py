import base64
import os

# Create assets directory
os.makedirs('assets', exist_ok=True)

# Minimal 1x1 dark blue PNG encoded in base64
# This is a valid PNG file with color #1A1A2E
png_b64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg=='

with open('assets/splash_logo.png', 'wb') as f:
    f.write(base64.b64decode(png_b64))

print('Created assets/splash_logo.png')
