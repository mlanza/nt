#!/usr/bin/env pwsh
nt page Skill --agent
nt tags Skill | sort | nt props description --heading 2
