#!/usr/bin/env pwsh
nt page Skills --agent
nt tags Skills | sort | nt props description | nt wikify
