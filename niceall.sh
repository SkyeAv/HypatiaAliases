#!/bin/bash

ps -u "$USER" -o pid= | xargs -n 1 renice -n 8 -p
