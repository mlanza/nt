#!/usr/bin/env pwsh
nt page Skill --less
nt tags Skill | sort | nt props situation | nt wikify
