#!/bin/bash
# Output clock face emoji matching current hour
hour=$(date +%I | sed 's/^0//')
emojis=(🕛 🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕚)
printf '%s' "${emojis[$((hour % 12))]}"
