#!/usr/bin/env pwsh
nt page Skill --less
nt tags Skill | sort | nt props description | nt wikify
