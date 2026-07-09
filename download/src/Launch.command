#!/bin/bash
# ============================================================
#  HARMLESS PRANK - no payload. This script only prints a
#  motivational message and waits for a keypress. Nothing is
#  downloaded, installed, modified, or sent anywhere.
# ============================================================
clear
cat <<'EOF'


   Go on hackthebox.com, lazyman.

   Pentesting is not automatable.
   Be strong with yourself and you will make the difference.
   Don't do like everyone else.


EOF
read -n 1 -s -r -p "Press any key to close..."
echo
